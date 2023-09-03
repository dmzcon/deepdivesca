#!/usr/bin/perl -w -I /opt/dda/ddacore/robots
use strict;
use DBI;
use DBD::Pg;
use Deepdiveautomation;

############################################
#### ROBOT INITIALIZATION STEP-1 ###########
############################################

my $dbh = DDAConnectToDB();

#############################################
##### ROBOT SETTINGS ########################
#############################################

my $who = "dda_robot_parser_cvedb";

my $ipc_relation_name = "status_$who";
my $runcontrol_name = "runcontrol_$who";
my $longterm_name = "longtermstatus_$who";

my $filename = "/opt/datalake_dda/workdir/vuln_info_parsing/cve-downloads/cvedb.xml";

my $sleeptimeout = 60;

#############################################
##### ROBOT GLOBALS  ########################
#############################################

my ($gstatus,$pstatus);

############################################
#### ROBOT INITIALIZATION STEP-2 ###########
############################################

DDAWriteToMainLog($who,"Starting CVEDB UPDATE parsing robot");

#############################################
####### STANDARD ROBOT ######################
#############################################

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

DDAWriteToMainLog($who,"CVEDB-UPDATE parsing job started");

open(FIL,"< $filename") or die "$who: Failure opening [$filename]: $!\n";
my $data = join("",<FIL>);
close(FIL);

my $status_query = "UPDATE intersystems_interconnection SET relation_flag=";

my $query_pattern1 = "SELECT id from cvedb WHERE item_name=";
my $query_pattern2 = "INSERT INTO cvedb (item_name,item_seq,item_type,item_status,phase_date,phase_state,item_descr,item_refs,item_votes,item_comments,record_creation_dt) VALUES (";
my $query_pattern3 = "UPDATE cvedb SET ";

my $new_rec_count = 0;
my $upd_rec_count = 0;
my $counter=0;

$data =~ s/<item\s+name=\"(CVE-[0-9]+-[0-9]+)\"\s+seq=\"([a-zA-Z0-9\-\_]*)\"\s+type=\"([a-zA-Z0-9\-\_]*)\"[\w\W]*?<status>([a-zA-Z0-9\-\_]*)<\/status>[\w\W]*?<phase\s+date=\"([0-9]+)\">([a-zA-Z0-9]*)<\/phase>[\w\W]*?<desc>([\w\W]*?)<\/desc>[\w\W]*?<refs>\s*([\w\W]*?)\s*<\/refs>([\w\W]*?)<\/item>/ my $item_name=$1; my $item_seq=$2; my $item_type=$3; my $item_status = $4; my $phase_date=$5; my $phase_state=$6; my $item_descr = $7; my $item_refs = $8; my $addblock=$9;     my $item_votes; my $item_comments; $addblock=~s#<votes>\s*([\w\W]*?)\s*<\/votes>#$item_votes = $1;"";#gme;   $addblock=~s#<comments>\s*([\w\W]*?)\s*<\/comments>#$item_comments = $1;"";#gme;          $item_descr=~s#'#&quot;#gm;  $item_refs=~s#'#&quot;#gm; $item_votes=~s#'#&quot;#gm; $item_comments=~s#'#&quot;#gm;    my $selectquery = $query_pattern1."'$item_name';"; my $selectsth=$dbh->prepare($selectquery); $selectsth->execute(); my ($frombaseid) = $selectsth->fetchrow_array(); $selectsth->finish(); unless($frombaseid) {my $tmp_query = $query_pattern2."'$item_name','$item_seq','$item_type','$item_status','$phase_date','$phase_state','$item_descr','$item_refs','$item_votes','$item_comments',NOW())"; my $sth=$dbh->prepare($tmp_query);$sth->execute();$sth->finish(); $new_rec_count++;} else { my $tmp_query = $query_pattern3."item_seq='$item_seq',item_type='$item_type',item_status='$item_status',phase_date='$phase_date',phase_state='$phase_state',item_descr='$item_descr',item_refs='$item_refs',item_votes='$item_votes',item_comments='$item_comments',record_lastchange_dt=NOW() where id=$frombaseid;"; my $updatesth=$dbh->prepare($tmp_query); $updatesth->execute(); $updatesth->finish(); $upd_rec_count++; if($counter%100 eq 0) {my $tmp_stat_query = $status_query."'UpdatedCount=$upd_rec_count',lastchange_dt=NOW() where relation_name='$longterm_name'"; my $statussth=$dbh->prepare($tmp_stat_query);$statussth->execute();$statussth->finish();} } $counter++;  "";/gem;

DDAWriteToMainLog($who,"CVEDB-UPDATE parsing job finished. Inserted $new_rec_count. Updated $upd_rec_count");




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
