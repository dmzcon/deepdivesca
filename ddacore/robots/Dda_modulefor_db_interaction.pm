package Dda_modulefor_db_interaction;
BEGIN {
        use Exporter();
        @ISA = "Exporter";
        @EXPORT = qw(DDA_DBSmartInsert_Component DDA_DBSmartInsert_Vulnerability DDA_DBFullfillVulnInfoByVulnID);
        #       @EXPORT_OK = qw(dbh);
}
use strict;
use DBI;
use DBD::Pg;
use Deepdiveautomation;

#######################################################################
############# DeepDiveAutomation DataBase API #########################
#######################################################################


sub     DDA_DBSmartInsert_Component {
        my ($who,$dbh,$oss_name,$purl_brief,$ecosystem,$version) = @_;
# Test and sanitarize the Input data
        unless($who and $dbh and $oss_name and $purl_brief and $ecosystem and $version) {
                return undef;
        }
        my ($sth,$comp_id,$release_id);
# Test if the Component already exitsts
        $sth = $dbh->prepare("SELECT id FROM oss_component WHERE oss_name='$oss_name' and purl_brief='$purl_brief' and ecosystem='$ecosystem' LIMIT 1");
        $sth->execute();
        ($comp_id) = $sth->fetchrow_array();
        $sth->finish();
        unless($comp_id) {
# Insert data into oss_component table if not exists
                $sth = $dbh->prepare("INSERT INTO oss_component (oss_name,purl_brief,ecosystem) VALUES ('$oss_name','$purl_brief','$ecosystem')");
                $sth->execute();
                $sth->finish();
# SUPER VERIFY that the INSERT was correct and successfull
                $sth = $dbh->prepare("SELECT id FROM oss_component WHERE oss_name='$oss_name' and purl_brief='$purl_brief' and ecosystem='$ecosystem' LIMIT 1");
                $sth->execute();
                ($comp_id) = $sth->fetchrow_array();
                $sth->finish();
                unless($comp_id) {
# INTEGRITY ERROR
                        return undef;
                }
        }
# Now work with the oss_releases table
# First we need to test if the info about corresponding version release already exitsts
        $sth = $dbh->prepare("SELECT id FROM oss_releases WHERE oss_id=$comp_id AND release_vers_name='$version' LIMIT 1");
        $sth->execute();
        ($release_id) = $sth->fetchrow_array();
        $sth->finish();
        unless($release_id) {
# Add the info about the release if not exists
                $sth = $dbh->prepare("INSERT INTO oss_releases (oss_id,create_dt,release_vers_name) VALUES ($comp_id,NOW(),'$version')");
                $sth->execute();
                $sth->finish();
# SUPER VERIFY that the INSERT about release was successfull
                $sth = $dbh->prepare("SELECT id FROM oss_releases WHERE oss_id=$comp_id AND release_vers_name='$version' LIMIT 1");
                $sth->execute();
                ($release_id) = $sth->fetchrow_array();
                $sth->finish();

                unless($release_id) {
# INTEGRITY ERROR
                        return undef;
                }
        }
        return $release_id;
}

##########################################################


sub     DDA_DBSmartInsert_Vulnerability {
        my ($who,$dbh,$component_id,$public_alias) = @_;
# Test and sanitarize the Input data
        unless($who and $dbh and $component_id and $public_alias) {
                return undef;
        }

        my ($vuln_id);
# Search existing vulnerability records by the ALIAS
        $sth = $dbh->prepare("SELECT id FROM vulns WHERE public_alias_list LIKE '%$public_alias%' AND oss_id=$component_id LIMIT 1");
        $sth->execute();
        ($vuln_id) = $sth->fetchrow_array();
        $sth->finish();
        unless($vuln_id) {
# INSERT new vulnerability record if not found
                $sth = $dbh->prepare("INSERT INTO vulns (public_alias_list,oss_id,create_dt) VALUES ('$public_alias',$component_id,NOW())");
                $sth->execute();
                $sth->finish();
# SUPER CHECK
                $sth = $dbh->prepare("SELECT id FROM vulns WHERE public_alias_list LIKE '%$public_alias%' AND oss_id=$component_id LIMIT 1");
                $sth->execute();
                ($vuln_id) = $sth->fetchrow_array();
                $sth->finish();
                unless($vuln_id) {
# INTEGRITY ERROR
                        return undef;
                }
        }
        return $vuln_id;
}

##########################################################

sub     DDA_DBFullfillVulnInfoByVulnID {
        my ($who,$dbh,$vuln_id,$add_alias,$vuln_summary,$vuln_descr) = @_;
# Test and sanitarize the Input data
        unless($who and $dbh and $vuln_id) {
                return undef;
        }


# Perform the fullfill job

        my $query_start = "UPDATE vulns SET lastchange_dt=NOW()";
        my $query_finish = " WHERE id=$vuln_id";
        unless($vuln_summary) {
        } else {
                $query_start .= ",issue_summary='$vuln_summary'";
        }
        unless($vuln_descr) {
        } else {
                $query_start .= ",vuln_descr='$vuln_descr'";
        }
        unless($add_alias) {
        } else {
                $query_start .= ",public_alias_list=CONCAT(public_alias_list,',$add_alias')";
        }
        $query_start .= $query_finish;
        $sth = $dbh($query_start);
        $sth->execute();

        return undef;
}



##########################################################





##########################################################





####################################################
####################################################
####################################################
return 1;
END {}
