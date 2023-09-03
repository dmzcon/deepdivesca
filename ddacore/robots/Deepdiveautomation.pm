package Deepdiveautomation;
BEGIN {
        use Exporter();
        @ISA = "Exporter";
        @EXPORT = qw(DDAWriteToDebugLog DDAWriteToMainLog DDAConnectToDB DDAGetGeneralStatus DDAGetPersonalStatus DDAUpdateFlag);
        #       @EXPORT_OK = qw(dbh);
}
use strict;
use DBI;
use DBD::Pg;

####################################################


my $debugfile = "/opt/dda/logs/debuglog";
my $mainlogfile = "/opt/dda/logs/errorlog";


####################################################
####################################################
####################################################

sub DDAWriteToDebugLog {
        my ($who, $message) = @_;
        open(LOGFILE, ">> $debugfile");
        print LOGFILE "$who: $message\n";
        close(LOGFILE);
}

####################################################

sub DDAWriteToMainLog {
        my ($who, $message) = @_;
        open(LOGFILE, ">> $mainlogfile");
        print LOGFILE "$who: $message\n";
        close(LOGFILE);
}


####################################################

sub DDAConnectToDB {
        my $dbname = '  ';
        my $host = 'localhost';
        my $port = '5432';
        my $username = '  ';
        my $password = '  ';

        my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",$username,$password,{AutoCommit => 1, RaiseError => 1}) or die "$!\n";
        return $dbh;
}

####################################################


sub     DDAGetGeneralStatus {
        my ($dbh)=@_;
        my $sth=$dbh->prepare("SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='status_general' LIMIT 1");
        $sth->execute();
        my ($status) = $sth->fetchrow_array();
        $sth->finish();
        return $status;
}


#############################################

sub     DDAGetPersonalStatus {
        my ($dbh,$runcontrol_name)=@_;
        my $sth=$dbh->prepare("SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='$runcontrol_name' LIMIT 1");
        $sth->execute();
        my ($status) = $sth->fetchrow_array();
        $sth->finish();
        return $status;
}


#############################################

sub     DDAUpdateFlag {
        my ($dbh,$relname,$newval,$who) = @_;

        DDAWriteToDebugLog($who,"DDAUpdateFlag performed query: [$relname] => [$newval]");
        my $sth=$dbh->prepare("UPDATE intersystems_interconnection SET relation_flag='$newval',lastchange_dt=NOW() WHERE relation_name='$relname'");
        $sth->execute();
        $sth->finish();
}





####################################################
####################################################
####################################################
return 1;
END {}
