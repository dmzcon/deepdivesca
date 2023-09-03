\c      deepdiveautomationdb;
---------------------------------------------------------
DELETE FROM conveyor_reports;
DROP TABLE conveyor_reports;

---------------------------------------------------------
CREATE TABLE conveyor_reports (
        id serial primary key,
        conveyor_id     integer not null,
        rec_create_dt       timestamp,
        who     varchar(255) not null,
        alert_message   TEXT not null default '-',
        alert_score     varchar(255) not null default '-',
        based_on_info   varchar(255) not null default '-'
);


---------------------------------------------------------

grant all on all sequences in schema public to ddadbadmin;
grant all on all tables in schema public to ddadbadmin;
