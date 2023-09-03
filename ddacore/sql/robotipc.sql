\c      deepdiveautomationdb;


DELETE from intersystems_interconnection;
DROP TABLE intersystems_interconnection;

CREATE TABLE intersystems_interconnection (
        id serial primary key,
        relation_name varchar(255) not null unique,
        relation_flag varchar(255),
        lastchange_dt   timestamp
);

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_general','OK');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_dwnldr_cvedb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_dwnldr_cvedb','RUN');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_dwnldr_ghadb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_dwnldr_ghadb','RUN');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_parser_cvedb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_parser_cvedb','PAUSE');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_parser_ghadb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_parser_ghadb','PAUSE');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_reader_sonatypeblog','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_reader_sonatypeblog','RUN');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_parser_sonatypeblog','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_parser_sonatypeblog','PAUSE');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_parser_cvedb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_parser_ghadb','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_parser_sonatypeblog','empty_status');


grant all on all sequences in schema public to ddadbadmin;

grant all on all tables in schema public to ddadbadmin;
