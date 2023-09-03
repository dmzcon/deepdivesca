\c      deepdiveautomationdb;

DELETE from oss_component;
DROP TABLE oss_component;
DELETE from vulns;
DROP TABLE vulns;
DELETE from vuln_ranges;
DROP TABLE vuln_ranges;


---------------------------------------------------------


---------------------------------------------------------

CREATE TABLE oss_component (
        id serial primary key,
        oss_name varchar(255) not null unique,
        external_comp_id integer default 0,
        purl_brief varchar(255) unique,
        ecosystem varchar(255)
);

---------------------------------------------------------

CREATE TABLE vulns (
        id serial primary key,
        oss_id  integer not null,
        public_alias_list       varchar(255),
        external_vuln_id integer default 0,
        issue_summary varchar(255),
        cvedb_id        integer default 0,
        gha_totalfilepath       varchar(255),
        conveyor_id     integer default 0,
        vuln_descr      text,
        cvss_info       text,
        create_dt       timestamp,
        lastchange_dt   timestamp
);


---------------------------------------------------------

CREATE TABLE vuln_ranges (
        id serial primary key,
        vuln_id         integer not null,
        external_vuln_cause_id  integer default 0,
        version_range   varchar(255) not null,
        create_dt       timestamp,
        lastchange_dt   timestamp
);



---------------------------------------------------------


grant all privileges on database deepdiveautomationdb to ddadbadmin;

grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
