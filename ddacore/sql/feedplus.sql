\c      feedplusdb;


create sequence analyze_requests_analyze_requests_id_seq;

create sequence vulnerability_component_version_ref_id_seq;

create table if not exists analyze_request
(
    analyze_request_id integer generated always as identity
        constraint analyze_requests_pkey
            primary key,
    purl               text not null
        constraint purl
            unique,
    create_time        text,
    is_done            boolean default false,
    result             text,
    last_request_time  date
);

comment on constraint purl on analyze_request is 'PURL unique constraint';

alter sequence analyze_requests_analyze_requests_id_seq owned by analyze_request.analyze_request_id;

create table if not exists component
(
    id               bigserial
        constraint pk_component
            primary key,
    purl             text
        constraint component_purl_unique
            unique,
    type             varchar(32),
    "group"          varchar(256),
    name             varchar(256),
    classifier       varchar(256),
    extension        varchar(16),
    validation_state integer default 0
);

create index if not exists purl_idx
    on component (purl);

create table if not exists component_version
(
    id           bigserial
        constraint pk_component_version
            primary key,
    component_id bigint
        constraint fk_component_version_component_id
            references component,
    version      varchar(256),
    qualifier    varchar(256),
    purl         text,
    publish_ts   timestamp,
    catalog_ts   timestamp,
    update_ts    timestamp,
    sha1         varchar(32),
    sha256       varchar(64),
    sha512       varchar(128),
    semver       varchar(2048),
    constraint component_id_version_unique
        unique (component_id, version)
);

create table if not exists license
(
    id           bigserial
        constraint pk_license
            primary key,
    name         varchar(256),
    license_text text,
    spdx_id      varchar(64),
    spdx_link    varchar(1024)
);

create table if not exists license_component_version_ref
(
    id         bigserial
        constraint pk_license_component_version_ref
            primary key,
    license_id bigint
        constraint fk_license_component_version_ref_license_id
            references license,
    version_id bigint
        constraint fk_license_component_version_ref_version_id
            references component_version,
    type       varchar(128),
    update_ts  timestamp
);

create table if not exists vulnerability
(
    id               bigserial
        constraint pk_vulnerability
            primary key,
    public_id        varchar(128)
        constraint public_id_unique
            unique,
    severity         integer,
    cwe              varchar(32),
    cvss_vector      varchar(128),
    source           varchar(32),
    url              varchar(1024),
    reference        varchar(1024),
    description      text,
    publish_ts       timestamp,
    update_ts        timestamp default now(),
    score            numeric(3, 1),
    category         varchar(32),
    description_full text,
    detection        text,
    explanation      text,
    recommendation   text
);

create table if not exists vulnerability_cause
(
    id         bigserial
        constraint pk_vulnerability_component_version_ref
            primary key,
    vulnerability_id    bigint
        constraint fk_vulnerability_component_version_ref_vulnerability_id
            references vulnerability,
    update_ts           timestamp,
    component_id        bigint
        constraint fk_vulnerability_cause_component_id
            references component,
    file                varchar(1024),
    class               varchar(256),
    method              varchar(256),
    snippet             text,
    cause_details       varchar(2048),
    version_range       varchar(4096),
    vulnerability_order varchar(16)[]
);

alter sequence vulnerability_component_version_ref_id_seq owned by vulnerability_cause.id;


grant all privileges on database feedplusdb to ddadbadmin;

grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
