\c      deepdiveautomationdb;

DROP TABLE      ghadb;
DROP TABLE      vuln_cause;

CREATE TABLE    ghadb  (
        id serial primary key,
        oss_id  integer,
        item_name      varchar(255) not null unique,
        aliases_block      varchar(255),
        related_block           varchar(255),
        modified_dt_text        varchar(255),
        published_dt_text       varchar(255),
        purl_brief              varchar(255),
        severity                text,
        database_specific       text,
        schema_version          varchar(255),
        item_summary            text,
        item_descr       text,
        item_refs       text,
        item_votes      text,
        item_comments   text,
        record_creation_dt      timestamp,
        record_lastchange_dt    timestamp
);


CREATE TABLE vuln_cause (
        id serial primary key,
        ghadb_vulnerability_id  integer not null,
        package_ecosystem       varchar(255),
        package_version_range   varchar(255),
        intro_version   varchar(255),
        fixed_version   varchar(255),
        last_affected_version   varchar(255),
        range_limit     varchar(255)
);


grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
