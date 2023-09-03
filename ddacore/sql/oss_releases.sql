\c      deepdiveautomationdb;

DELETE from oss_releases;
DROP TABLE oss_releases;

DELETE from dep_list;
DROP TABLE dep_list;

---------------------------------------------------------

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_actualizer_relinfo';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_actualizer_relinfo';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_actualizer_relinfo';

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_actualizer_relinfo','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_actualizer_relinfo','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_actualizer_relinfo','empty_status');

---------------------------------------------------------

CREATE TABLE oss_releases (
        id serial primary key,
        oss_id  integer not null,
        create_dt       timestamp,
        lastchange_dt   timestamp,
        release_vers_name       varchar(255) not null,
        release_url     varchar(255) default '-',
        release_dt      timestamp
);

---------------------------------------------------------

CREATE TABLE dep_list (
        id serial primary key,
        release_id      integer not null,
        dep_item_coninfo        varchar(255) not null default '-'
);


---------------------------------------------------------


grant all privileges on database deepdiveautomationdb to ddadbadmin;

grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
