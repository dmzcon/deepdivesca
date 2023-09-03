\c      deepdiveautomationdb;

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_logs_handler';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_logs_handler';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_logs_handler';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_conveyor_dwnldr';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_conveyor_dwnldr';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_conveyor_dwnldr';


DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_malware_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_malware_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_malware_l1';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_malware_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_malware_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_malware_l2';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_vulnsearch_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_vulnsearch_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_vulnsearch_l1';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_vulnsearch_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_vulnsearch_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_vulnsearch_l2';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_someware_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_someware_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_someware_l1';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_someware_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_someware_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_someware_l2';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_apt_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_apt_l1';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_apt_l1';

DELETE FROM intersystems_interconnection WHERE relation_name = 'status_dda_robot_analyzer_apt_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'runcontrol_dda_robot_analyzer_apt_l2';
DELETE FROM intersystems_interconnection WHERE relation_name = 'longtermstatus_dda_robot_analyzer_apt_l2';



INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_logs_handler','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_logs_handler','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_logs_handler','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_conveyor_dwnldr','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_conveyor_dwnldr','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_conveyor_dwnldr','empty_status');



INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_malware_l1','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_malware_l1','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_malware_l1','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_malware_l2','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_malware_l2','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_malware_l2','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_vulnsearch_l1','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_vulnsearch_l1','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_vulnsearch_l1','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_vulnsearch_l2','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_vulnsearch_l2','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_vulnsearch_l2','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_someware_l1','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_someware_l1','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_someware_l1','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_someware_l2','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_someware_l2','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_someware_l2','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_apt_l1','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_apt_l1','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_apt_l1','empty_status');

INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('status_dda_robot_analyzer_apt_l2','empty_status');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('runcontrol_dda_robot_analyzer_apt_l2','RUN');
INSERT INTO intersystems_interconnection (relation_name,relation_flag) values ('longtermstatus_dda_robot_analyzer_apt_l2','empty_status');




DROP TABLE handler_conveyor;

CREATE TABLE handler_conveyor (
        id serial primary key,
        purl_brief varchar(255) not null,
        version varchar(255) not null,
        release_id      integer default 0,
        record_create_dt timestamp,
        dwnldr_status   varchar(255) default 'ToDo',
        dwnldr_link     varchar(255) default 'Unknown',
        url2_link       varchar(255) default 'Unknown',
        workdirpath     varchar(255) default 'Unknown',

        score_dda_robot_analyzer_malware_l1     varchar(255) default '-',
        status_dda_robot_analyzer_malware_l1    varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_malware_l1 timestamp,

        score_dda_robot_analyzer_malware_l2     varchar(255) default '-',
        status_dda_robot_analyzer_malware_l2    varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_malware_l2 timestamp,

        score_dda_robot_analyzer_vulnsearch_l1  varchar(255) default '-',
        status_dda_robot_analyzer_vulnsearch_l1 varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_vulnsearch_l1 timestamp,

        score_dda_robot_analyzer_vulnsearch_l2  varchar(255) default '-',
        status_dda_robot_analyzer_vulnsearch_l2 varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_vulnsearch_l2 timestamp,

        score_dda_robot_analyzer_someware_l1 varchar(255) default '-',
        status_dda_robot_analyzer_someware_l1        varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_someware_l1 timestamp,

        score_dda_robot_analyzer_someware_l2 varchar(255) default '-',
        status_dda_robot_analyzer_someware_l2        varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_someware_l2 timestamp,

        score_dda_robot_analyzer_apt_l1 varchar(255) default '-',
        status_dda_robot_analyzer_apt_l1        varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_apt_l1 timestamp,

        score_dda_robot_analyzer_apt_l2 varchar(255) default '-',
        status_dda_robot_analyzer_apt_l2        varchar(255) default 'ToDo',
        updatedt_dda_robot_analyzer_apt_l2 timestamp

);




grant all on all sequences in schema public to ddadbadmin;
grant all on all tables in schema public to ddadbadmin;
