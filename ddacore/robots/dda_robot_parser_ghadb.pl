#!/usr/bin/perl -w -I /opt/dda/ddacore/robots
use strict;
use DBI;
use DBD::Pg;
use Deepdiveautomation;
use locale;
use Dda_modulefor_robot_parser_ghadb;

############################################
#### ROBOT INITIALIZATION STEP-1 ###########
############################################

my $dbh = DDAConnectToDB();

#############################################
##### ROBOT SETTINGS ########################
#############################################

my $who = "dda_robot_parser_ghadb";

my $ipc_relation_name = "status_$who";
my $runcontrol_name = "runcontrol_$who";
my $longterm_name = "longtermstatus_$who";

my $workdir = "/opt/datalake_dda/workdir/vuln_info_parsing/ghadb/fromgithub/advisory-database/advisories";
my $revieweddir = "github-reviewed";
my $unreviewed = "unreviewed";

my $sleeptimeout = 60;

my ($gstatus,$pstatus);

#############################################
##### ROBOT GLOBALS  ########################
#############################################

my $count = 0;
my $nocvecount = 0;
my $approxi_match_count = 0;

############################################
#### ROBOT INITIALIZATION STEP-2 ###########
############################################

DDAWriteToMainLog($who,"Starting GHADB UPDATE parsing robot");

#my $feedplusdbh = DBI -> connect("dbi:Pg:dbname='feedplusdb';host='localhost';port='5432'",'ddadbadmin','ddadbadminpassword',{AutoCommit => 1, RaiseError => 1}) or die "$!\n";
my $feedplusdbh = DBI -> connect("dbi:Pg:dbname='feedplusdb';host='localhost';port='5432'",'scaadm','sca31337adm',{AutoCommit => 1, RaiseError => 1}) or die "$!\n";

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


                DDAWriteToMainLog($who,"Starting GHADB-UPDATE parsing job");
                $count = 0;
                $nocvecount = 0;
                $approxi_match_count = 0;

opendir(DIRS, "$workdir/$revieweddir");

my @dir_years_list = readdir(DIRS);
close(DIRS);

foreach my $year (@dir_years_list) {
        if($year =~ m/[0-9]+/) {
                opendir(MONDIR,"$workdir/$revieweddir/$year");
                my @monthlist = readdir(MONDIR);
                closedir(MONDIR);
                foreach my $month (@monthlist) {
                        if($month =~ m/[0-9a-zA-Z\-\_]+/) {
                                opendir(MAINLIST,"$workdir/$revieweddir/$year/$month");
                                my @mainlist = readdir(MAINLIST);
                                closedir(MAINLIST);
                                foreach my $vulnrecord (@mainlist) {
                                        if($vulnrecord =~ m/[\w\W]{3,}/) {
                                                $count ++;
                                                #printf "Parsing vuln. #$count: $workdir/$revieweddir/$year/$month/$vulnrecord\n";
                                                opendir(VULN,"$workdir/$revieweddir/$year/$month/$vulnrecord");
                                                my @vlist = readdir(VULN);
                                                closedir(VULN);
                                                my $i=0;
                                                foreach my $v (@vlist) {
                                                        $i++;
                                                        if($v =~ m/[\w\W]{3,}/) {

                                                                #########################################
                                                                #########################################
                                                                #########################################

my $totalfilepath = "$workdir/$revieweddir/$year/$month/$vulnrecord/$v";


open(FILE,"$workdir/$revieweddir/$year/$month/$vulnrecord/$v") or die "$who: Could not open file [$workdir/$revieweddir/$year/$month/$vulnrecord/$v]: $!\n";
my $file = join("",<FILE>);
close($file);

my ($ghaid,$public_id,$aliases, $summary, $details, $block0, $block00, $block1, $block2, $affected, $db_spec, $purl_brief, $purl_full, $cvssvector,$severity);


$file =~ s/schema_version[\w\W]+?\"id\"[\s\:]+?\"([\w\W]+?)details[\"\s\:]+([\w\W]+?)\"[,\s\"]+(severity[\"\:\s]+[\w\W]+?)references\"\:\s*([\w\W]+)/$block0 = $1;$details=$2; $block1 = $3; $block2 = $4; $block00=$block0; unless($block0) { DDAWriteToDebugLog($who,"Attention EMPTY-BLOCK0 at [$totalfilepath]");  } $block0 =~ s#([a-zA-Z\-\_0-9]+?)\"[\w\W]+?aliases[\"\:\s]+?\[([\w\W]*?)\][\w\W]+summary[\:\"\s]+([\w\W]+?)\"#$ghaid=$1; $aliases=$2; $summary=$3; "";#gem; $public_id=$ghaid; unless($aliases) { DDAWriteToDebugLog($who,"Attention EMPTY-ALIASES at [$totalfilepath] with block0=[$block00]"); } else { $aliases=~s#\s##gm;  $aliases=~s#(CVE-[0-9\-]+)#$public_id=$1;"";#ge; }   unless($summary) {  DDAWriteToDebugLog($who,"Attention EMPTY-SUMMARY at [$totalfilepath] with block0=[$block00]"); $summary='-'; }    "";/gme;

#print "$totalfilepath: Part-1 [ghaid=$ghaid][publicid=$public_id] block1=[$block1] passed\n";

unless($details) { DDAWriteToDebugLog($who,"Attention EMPTY-DETAILS at [$totalfilepath]"); }

unless($block1) { DDAWriteToDebugLog($who,"Attention EMPTY-BLOCK1 at [$totalfilepath]"); }

$block1 =~ s/severity[\s\:\"]+([\w\W]+?)\]/$severity = $1; "";/em;

#print "$totalfilepath: Part-1a [ghaid=$ghaid][publicid=$public_id] block1=[$block1] passed\n";

$severity =~ s/\"score\"[\:\"\s]+([\w\W]+?)\"/$cvssvector = $1;"";/em;
unless($cvssvector) { $cvssvector = "-"; }


#print "$totalfilepath: Part-2 [cvssvector=$cvssvector] public_id=[$public_id] passed\n";

my $component_id;
my $vulnerability_id;

$block1 =~ s/ckage[\"\s\:\{]+ecosystem[\"\s\:]+\"([\w\W]*?)\"[\s\"\,]+name[\:\s\"]+([\w\W]+?)\"[\s\}\,\"]+([\w\W]+?)\}\s*,\s*\{\s*\"pa/my $ecosystem = $1; my $vulnid; my $name = $2; my $block4=$3; unless($ecosystem) {   DDAWriteToDebugLog($who,"Attention EMPTY-ECOSYSTEM at [$totalfilepath]"); } unless($name) { DDAWriteToDebugLog($who,"Attention EMPTY-NAME at [$totalfilepath]");  }  $name =~ tr#A-Z#a-z#; $ecosystem=~tr#A-Z#a-z#; $name=~s#\:#\/#g; $name=~s#\@##gm; unless($block4) { DDAWriteToDebugLog($who,"Attention EMPTY-BLOCK4 at [$totalfilepath]");      }  my $version='-'; my $fixvers="unknown"; $block4=~s#versions[\s\:\"\[]+([\w\W]+?)\"#$version=$1;"";#gem; if($version eq "-") { $block4=~s#introduced[\s\:\"\[]+\"([\w\W]+?)\"[\"\s\]\}\,\{]+fixed[\"\:\s\[]+([\w\W]+?)\"#$version=$1;$fixvers=$2;"";#gem;   } if($version eq "-") {$version = ' ';}  $purl_brief="pkg:$ecosystem\/$name"; $component_id=FindCompByPurlBrief($feedplusdbh,$purl_brief); unless($component_id) { $component_id=InsertNewComponent($feedplusdbh,$purl_brief,$ecosystem,$name); } $vulnerability_id=FindVulnByPublicID($feedplusdbh,$public_id); unless($vulnerability_id) { $vulnerability_id=InsertNewVulnerability($feedplusdbh,$public_id,$cvssvector,$summary,$details);}   my $vulncause_exists=FindVulnCauseF1($feedplusdbh,$purl_brief,$public_id,$version,$fixvers);  unless($vulncause_exists) { my $vulncause_id=FindVulnCauseF2($feedplusdbh,$purl_brief,$public_id); unless($vulncause_id) {} else {$approxi_match_count++;}  InsertNewVulnCause($feedplusdbh,$vulnerability_id,$component_id,$version,$fixvers,$ecosystem,$name);  }   else {  DDAWriteToDebugLog($who,"DO NOTHING (found exact match with GHA-base): $purl_brief\@$version\t\t[$public_id]"); }    "";/gem;




$block2 =~ s/database_specific[\"\s\:\{]+([\w\W]+?)\}/$db_spec = $1; unless($db_spec) { DDAWriteToDebugLog($who,"Attention EMPTY-DBSPEC at [$totalfilepath]"); } "";/gem;



                                                                #########################################
                                                                #########################################
                                                                #########################################
                                                        }
                                                }
                                                if($i ne 3) {
                                                        DDAWriteToMainLog($who,"\n\n\nAttention at vuln. #$count: $workdir/$revieweddir/$year/$month/$vulnrecord\n\n\n");
                                                }
                                        }
                                }
                        }
                }
        }
}


DDAWriteToMainLog($who,"The GHADB-UPDATE parsing job finished. Count=$count, noAliasCount=$nocvecount");



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
$feedplusdbh->disconnect();

exit(0);
