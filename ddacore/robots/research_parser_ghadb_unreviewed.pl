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
my $unrevieweddir = "unreviewed";
my $unreviewed = "unreviewed";

my $sleeptimeout = 60;

my ($gstatus,$pstatus);

#############################################
##### ROBOT GLOBALS  ########################
#############################################

my $totalcount = 0;
my $oss_vuln_count=0;
my $count_pypi = 0;
my $count_maven = 0;
my $count_npm = 0;
my $count_golang = 0;
my $count_empty_alias = 0;
my $count_empty_affected = 0;
my $count_empty_details = 0;

############################################
#### ROBOT INITIALIZATION STEP-2 ###########
############################################




#############################################
######### ROBOT MAIN JOB ####################
#############################################


opendir(DIRS, "$workdir/$unrevieweddir");

my @dir_years_list = readdir(DIRS);
close(DIRS);

foreach my $year (@dir_years_list) {
        if($year =~ m/[0-9]+/) {
                opendir(MONDIR,"$workdir/$unrevieweddir/$year");
                my @monthlist = readdir(MONDIR);
                closedir(MONDIR);
                foreach my $month (@monthlist) {
                        if($month =~ m/[0-9a-zA-Z\-\_]+/) {
                                opendir(MAINLIST,"$workdir/$unrevieweddir/$year/$month");
                                print "Researching directory $workdir/$unrevieweddir/$year/$month\n";
                                my @mainlist = readdir(MAINLIST);
                                closedir(MAINLIST);
                                foreach my $vulnrecord (@mainlist) {
                                        if($vulnrecord =~ m/[\w\W]{3,}/) {
                                                #printf "Parsing vuln. #$count: $workdir/$revieweddir/$year/$month/$vulnrecord\n";
                                                opendir(VULN,"$workdir/$unrevieweddir/$year/$month/$vulnrecord");
                                                my @vlist = readdir(VULN);
                                                closedir(VULN);
                                                my $i=0;
                                                foreach my $v (@vlist) {
                                                        $i++;
                                                        if($v =~ m/[\w\W]{3,}/) {
                                                                #########################################
                                                                #########################################
                                                                #########################################

my $totalfilepath = "$workdir/$unrevieweddir/$year/$month/$vulnrecord/$v";

#print "Start parse [$totalfilepath]\n";

open(FILE,"$workdir/$unrevieweddir/$year/$month/$vulnrecord/$v") or die "$who: Could not open file [$workdir/$unrevieweddir/$year/$month/$vulnrecord/$v]: $!\n";
my $file = join("",<FILE>);
close($file);
#print "File opened and read [$totalfilepath]\n";

if($file =~ m/(pypi\.org|npmjs\.com|pkg\.go\.dev)/gim) {
        my $r = $1;
        #       print "found [$r]\n";
        if($r =~ m/pypi/i) {
                $file =~ s/\:\s*(\"[\w\W]{,10}pypi\.org\/project\/[\w\W]*?\")/print "[PYPI][$totalfilepath]:\n$1\n";"";/geim;
                $count_pypi++;
        } elsif($r =~ m/npm/i) {
                $file =~ s/\:\s*(\"[\w\W]{,20}npmjs\.com\/package\/[\w\W]*?\")/print "[NPM][$totalfilepath]:\n$1\n";"";/geim;
                $count_npm++;
        } elsif($r =~ m/go/i) {
                $file =~ s/\:\s*(\"[\w\W]{,20}pkg\.go\.dev\/vuln\/[\w\W]*?\")/print "[GOLANG][$totalfilepath]:\n$1\n";"";/geim;
                $count_golang++;
        }
        $oss_vuln_count++;
if($file =~ m/aliases\"\:\s*\[\s*\]/gim) {
                print "EMPTY-ALIAS - [$totalfilepath]\n";
        $count_empty_alias++;
}
if($file =~ m/affected\"\:\s*\[\s*\]/gim) {
                print "EMPTY-AFFECTED - [$totalfilepath]\n";
        $count_empty_affected++;
}
if($file =~ m/details\"\:\s*\[\s*\]/gim) {
                print "EMPTY-DETAILS - [$totalfilepath]\n";
        $count_empty_details++;
}

} elsif($file =~ m/maven/gim) {
                $file =~ s/([\w\W]{,80}maven[\w\W]{,80})/print "[MAVEN][$totalfilepath]:\n$1\n";"";/geim;
} elsif($file =~ m/nuget/gim) {
                $file =~ s/([\w\W]{,80}nuget[\w\W]{,80})/print "[NUGET][$totalfilepath]:\n$1\n";"";/geim;
}


$totalcount++;




                                                                #########################################
                                                                #########################################
                                                                #########################################
                                                        }
                                                }
                                                if($i ne 3) {
                                                        print "Attention at vuln. #$totalcount: $workdir/$unrevieweddir/$year/$month/$vulnrecord\n";
                                                }
                                        }
                                }
                        }
                }
        }
}


print "\n\nSTATISTICS:\ntotalcount=$totalcount\noss_vuln_count=$oss_vuln_count\nPypi issues: $count_pypi\nNPM issues: $count_npm\nGOLANG issues: $count_golang\n\n------\nINCLUDING:\nEmpty ALIAS-fields: $count_empty_alias\nEmpty AFFECTED-fields: $count_empty_affected\nEmpty DETAILS-fields: $count_empty_details\n";

#############################################
######### ROBOT MAIN JOB FINISHED ###########
#############################################


$dbh->disconnect();
#$feedplusdbh->disconnect();

exit(0);
