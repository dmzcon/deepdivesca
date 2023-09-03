#!/usr/bin/perl -w -I /opt/dda/ddacore/robots
use strict;
use DBI;
use DBD::Pg;
use Deepdiveautomation;

############################################
#### ROBOT INITIALIZATION ##################
############################################

my $dbh = DDAConnectToDB();

#############################################
##### ROBOT SETTINGS ########################
#############################################

my $who = "dda_robot_parser_sonatypeblog"; # without extention

my $ipc_relation_name = "status_$who";
my $runcontrol_name = "runcontrol_$who";
my $longterm_name = "longtermstatus_$who";


my $filename = "/opt/datalake_dda/workdir/vuln_info_parsing/cve-downloads/cvedb.xml";
my $sleeptimeout = 60;

#############################################
##### ROBOT GLOBALS  ########################
#############################################

my ($gstatus,$pstatus);

#############################################
####### STANDARD ROBOT ######################
#############################################


DDAWriteToMainLog($who,"Starting SONATYPEBLOG parsing robot");

while (1) {

        $gstatus = DDAGetGeneralStatus($dbh);
        unless($gstatus and $gstatus eq 'OK') {
                DDAWriteToMainLog($who,"G-Exiting...");
                DDAUpdateFlag($dbh,$ipc_relation_name,'G-Off',$who);
                exit(0);
        }
        $pstatus = DDAGetPersonalStatus($dbh,$runcontrol_name);
        unless($pstatus and $pstatus ne 'STOP') {
                DDAWriteToMainLog($who,"P-Exiting...");
                DDAUpdateFlag($dbh,$ipc_relation_name,'P-Off',$who);
                exit(0);
        } elsif($pstatus eq 'RUN') {
                DDAUpdateFlag($dbh,$ipc_relation_name,'Running',$who);

#############################################
######### ROBOT MAIN JOB ####################
#############################################

        DDAWriteToMainLog($who,"Starting SONATYPEBLOG parser job");






        DDAWriteToMainLog($who,"SONATYPEBLOG parser job finished");

#############################################
######### ROBOT MAIN JOB FINISHED ###########
#############################################
                DDAUpdateFlag($dbh,$ipc_relation_name,'Calculation completed. Now go to sleep...',$who);
                DDAUpdateFlag($dbh,$runcontrol_name,'PAUSE',$who);
                sleep(10);
        } elsif($pstatus eq 'PAUSE') {
                DDAUpdateFlag($dbh,$ipc_relation_name,'Suspended, do nothing, waiting status change',$who);
        }

        sleep($sleeptimeout);
}

#############################################

$dbh->disconnect();
exit(0);
