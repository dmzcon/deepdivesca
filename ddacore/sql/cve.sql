\c      deepdiveautomationdb;

DROP TABLE      cvedb;

CREATE TABLE    cvedb  (
        id serial primary key,
        oss_id  integer,
        item_name      varchar(255) not null,
        item_seq        varchar(255),
        item_type       varchar(255),
        item_status      varchar(255),
        phase_date      varchar(255),
        phase_state     varchar(255),
        item_descr       text,
        item_refs       text,
        item_votes      text,
        item_comments   text,
        record_creation_dt      timestamp,
        record_lastchange_dt    timestamp
);


grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
