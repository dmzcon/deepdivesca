package Dda_modulefor_robot_parser_ghadb;
BEGIN {
        use Exporter();
        @ISA = "Exporter";
        @EXPORT = qw(FindCompByPurlBrief InsertNewComponent FindVulnCauseF1 FindVulnCauseF2 FindVulnByPublicID InsertNewVulnerability InsertNewVulnCause);
        #       @EXPORT_OK = qw(dbh);
}
use strict;
use DBI;
use DBD::Pg;
use Deepdiveautomation;

##########################################################
##########################################################


##########################################################

sub FindCompByPurlBrief {
        my ($feedplusdbh,$purl_brief) = @_;
        my $select_search_component = "SELECT feed.component.id FROM feed.component WHERE feed.component.purl=";
        my $search_purl_sth=$feedplusdbh->prepare($select_search_component."'$purl_brief' LIMIT 1");
        $search_purl_sth->execute();
        my ($comp_id)=$search_purl_sth->fetchrow_array();
        $search_purl_sth->finish();
        unless($comp_id and $comp_id =~ m/[0-9]+/) {
                DDAWriteToDebugLog("GHADB-parser","For purl=[$purl_brief] component not found");
        }
        return $comp_id;
}

##########################################################

sub InsertNewComponent {
        my ($feedplusdbh,$purl_brief,$ecosystem,$name) = @_;
        if($purl_brief =~ m/[\w\W]{5,}/) {
        } else {
                DDAWriteToMainLog("GHADB-parser","\n\n\n-----------\nINTEGRITY CRITICAL ERROR [WRONG-PURL]: $feedplusdbh,$purl_brief,$ecosystem,$name\n-----------\n\n\n");
                return "WRONG-PURL-STOP";
        }

        my $new_component_query = "INSERT INTO feed.component (purl,type,name,source) VALUES (";
        my $new_component_sth=$feedplusdbh->prepare("$new_component_query'$purl_brief','$ecosystem','$name','GHADB-REVIEWED')");
        $new_component_sth->execute();
        $new_component_sth->finish();

        my $comp_id = FindCompByPurlBrief($feedplusdbh,$purl_brief);
        unless($comp_id) {
                DDAWriteToMainLog("GHADB-parser","\n\n\n-----------\nINTEGRITY CRITICAL ERROR [EMPTY-COMPONENT-ID]: $feedplusdbh,$purl_brief,$ecosystem,$name\n-----------\n\n\n");
                return "WRONG-COMPID-STOP";
        }
        DDAWriteToDebugLog("GHADB-parser","Inserted new component [$purl_brief][$comp_id]");


        return $comp_id;
}

##########################################################

sub FindVulnCauseF1 {
        my ($feedplusdbh,$purl_brief,$cveid,$introduced_version,$fixed_version) = @_;

        my $range;
        unless($introduced_version and ($introduced_version =~ m/[a-zA-Z0-9\.\_\-]/) ) {
                $range = "(,";
        } else {
                $range = "[$introduced_version,";
        }
        unless($fixed_version and ($fixed_version ne 'unknown')) {
                $range = $range.")";
        } else {
                $range = $range."$fixed_version)";
        }

        #       print "SEARCH F1: [$purl_brief,$cveid,$range]\n";

        my $select1_query = "SELECT feed.vulnerability_cause.id,feed.vulnerability_cause.version_range,feed.vulnerability_cause.vulnerability_id FROM feed.component,feed.vulnerability_cause,feed.vulnerability WHERE feed.component.id=feed.vulnerability_cause.component_id AND feed.component.purl='$purl_brief' AND feed.vulnerability_cause.vulnerability_id=feed.vulnerability.id AND feed.vulnerability.public_id='$cveid' AND feed.vulnerability_cause.version_range='$range'";

        my $feedsth=$feedplusdbh->prepare($select1_query);
        $feedsth->execute();

        my ($cause_id,$vrange,$vid);
        my @tmpres;
        my $tmpc = 0;
        while(@tmpres = $feedsth->fetchrow_array()) {
                ($cause_id,$vrange,$vid) = @tmpres;
                $tmpc++;
        }
        if($tmpc>1) {
                DDAWriteToMainLog("GHADB-parser","Doubles found for [$cveid]. Doubles_count=$tmpc. Use PoC-query: $select1_query\n\n");
        }
        $feedsth->finish();

        return $cause_id;
}

##########################################################

sub FindVulnCauseF2 {
        my ($feedplusdbh,$purl_brief,$cveid) = @_;

        #       print "SEARCH F2: [$purl_brief,$cveid]\n";

        my $select1_query = "SELECT feed.vulnerability_cause.id,feed.vulnerability_cause.version_range,feed.vulnerability_cause.vulnerability_id FROM feed.component,feed.vulnerability_cause,feed.vulnerability WHERE feed.component.id=feed.vulnerability_cause.component_id AND feed.component.purl='$purl_brief' AND feed.vulnerability_cause.vulnerability_id=feed.vulnerability.id AND feed.vulnerability.public_id='$cveid' LIMIT 1";

        my $feedsth=$feedplusdbh->prepare($select1_query);
        $feedsth->execute();

        my ($cause_id,$vrange,$vid) = $feedsth->fetchrow_array();

        $feedsth->finish();

        return $cause_id;
}

##########################################################

sub FindVulnByPublicID {
        my ($feedplusdbh,$cveid) = @_;
        unless($feedplusdbh) {
                DDAWriteToMainLog("GHADB-parser","Find returned CRITICAL ERROR UNDEFINED-DBH\n");
                return "UNDEFINED-DBH-STOP";
        } else {
                #               print "Find got dbh=[$feedplusdbh]\n";
        }

        unless($cveid) {
                DDAWriteToMainLog("GHADB-parser","Find returned CRITICAL ERROR UNDEFINED-PUBLIC-ID (dbh=$feedplusdbh)\n");
                return "UNDEFINED-PUBLIC-ID-STOP";
        } elsif($cveid =~ m/[\w\W]{4,}/) {
        } else {
                DDAWriteToMainLog("GHADB-parser","Find returned CRITICAL ERROR WRONG-PUBLIC-ID:$cveid\n");
                return "EMPTY-PUBLIC-ID-STOP";
        }


        my $select1_query = "SELECT feed.vulnerability.id FROM feed.vulnerability WHERE feed.vulnerability.public_id='$cveid' LIMIT 1";

        my $feedsth=$feedplusdbh->prepare($select1_query);
        $feedsth->execute();

        my ($res) = $feedsth->fetchrow_array();

        $feedsth->finish();
        return $res;
}

##########################################################

sub InsertNewVulnerability {
        my ($feedplusdbh,$cveid,$cvssvector,$summary,$details) = @_;

        #       print "------ > [$cvssvector,$summary,$details]\n";

        unless($feedplusdbh) {
                DDAWriteToMainLog("GHADB-parser","Insert returned CRITICAL ERROR UNDEFINED-DBH\n");
                return "UNDEFINED-DBH-STOP";
        } else {
                #       print "Insert got dbh=[$feedplusdbh]\n";
        }
        unless($cveid) {
                DDAWriteToMainLog("GHADB-parser","Insert returned CRITICAL ERROR UNDEFINED-PUBLIC-ID (dbh=$feedplusdbh)\n");
                return "UNDEFINED-PUBLIC-ID-STOP";
        } elsif($cveid =~ m/[\w\W]{4,}/) {
        } else {
                DDAWriteToMainLog("GHADB-parser","Insert returned CRITICAL ERROR WRONG-PUBLIC-ID:$cveid\n");
                return "EMPTY-PUBLIC-ID-STOP";
        }

        $summary =~ s/'/&quot;/gm;
        $details =~ s/'/&quot;/gm;
        $summary =~ s/"/&quot;/gm;
        $details =~ s/"/&quot;/gm;

        # print "INSERTING: [$summary],[$details]\n";

        my $insert_query = "INSERT INTO feed.vulnerability (public_id,cvss_vector,source,description,category,description_full) VALUES ('$cveid','$cvssvector','GHADB-REVIEWED','$summary','vulnerability','$details')";
        my $ins_sth = $feedplusdbh->prepare($insert_query);
        $ins_sth->execute();
        $ins_sth->finish();

        my $vulnid = FindVulnByPublicID($feedplusdbh,$cveid);

        DDAWriteToDebugLog("GHADB-parser","Inserted new vulnerability (PUBLICID='$cveid')\n");

        return $vulnid;
}

##########################################################


sub InsertNewVulnCause {
        my ($feedplusdbh,$vuln_id,$comp_id,$introduced_version,$fixed_version,$ecosystem,$name) = @_;
        unless($vuln_id and $comp_id) {
                DDAWriteToMainLog("GHADB-parser","\n\n\n-----------\nINTEGRITY CRITICAL ERROR [WRONG-KEYS]: $feedplusdbh,$vuln_id,$comp_id,$introduced_version,$fixed_version,$ecosystem,$name\n-----------\n\n\n");
                return;
        }

        my $range;
        unless($introduced_version and ($introduced_version =~ m/[a-zA-Z0-9\.\_\-]/) ) {
                $range = "(,";
        } else {
                $range = "[$introduced_version,";
        }
        unless($fixed_version and ($fixed_version ne 'unknown')) {
                $range = $range.")";
        } else {
                $range = $range."$fixed_version)";
        }


        $ecosystem =~ tr/a-z/A-Z/;

        my $insert_query = "INSERT INTO feed.vulnerability_cause (vulnerability_id, component_id, cause_details, version_range, source, update_ts) VALUES ($vuln_id,$comp_id,'$ecosystem package $name $range is vulnerable','$range','GHADB-REVIEWED',NOW())";

        # print "$insert_query\n";

        my $ins_sth = $feedplusdbh->prepare($insert_query);
        $ins_sth->execute();
        $ins_sth->finish();

        DDAWriteToDebugLog("GHADB-parser","Inserted new vuln_cause (vuln_id=$vuln_id,comp_id=$comp_id)\n-------\n");
}


##########################################################


####################################################
####################################################
####################################################
return 1;
END {}
