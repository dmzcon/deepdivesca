import  psycopg2
import  deepdiveautomation

#######################################################################
############# DeepDiveAutomation DataBase API #########################
#######################################################################


def     DDA_DBSmartInsert_Component(who,dbh,oss_name,purl_brief,ecosystem,version): 
# Test and sanitarize the Input data
    if((who is None) or (dbh is None) or (oss_name is None) or (purl_brief is None) or (ecosystem is None) or (version is None)): 
        return None;
        
# Test if the Component already exitsts
    comp_id = 0
    release_id = 0
    sth = dbh.cursor()
    sth.execute("SELECT id FROM oss_component WHERE oss_name='"+oss_name+"' and purl_brief='"+purl_brief+"' and ecosystem='"+ecosystem+"' LIMIT 1")
    row = sth.fetchone()
    sth.close()
    if row is None:
# Insert data into oss_component table if not exists
        sth = dbh.cursor()
        sth.execute("INSERT INTO oss_component (oss_name,purl_brief,ecosystem) VALUES ('"+oss_name+"','"+purl_brief+"','"+ecosystem+"')")
        sth.close()
# SUPER VERIFY that the INSERT was correct and successfull
        sth = dbh.cursor()
        sth.execute("SELECT id FROM oss_component WHERE oss_name='"+oss_name+"' and purl_brief='"+purl_brief+"' and ecosystem='"+ecosystem+"' LIMIT 1")
        row = sth.fetchone()
        sth.close()
        if row is None:
# INTEGRITY ERROR
            return None
        comp_id = row[0]
    else:
        comp_id = row[0]
# Now work with the oss_releases table
# First we need to test if the info about corresponding version release already exitsts
    sth = dbh.cursor()
    sth.execute("SELECT id FROM oss_releases WHERE oss_id="+str(comp_id)+" AND release_vers_name='"+version+"' LIMIT 1")
    row = sth.fetchone()
    sth.close()
    if row is None:
# Add the info about the release if not exists
        sth = dbh.cursor()
        sth.execute("INSERT INTO oss_releases (oss_id,create_dt,release_vers_name) VALUES ("+str(comp_id)+",NOW(),'"+version+"')")
        sth.close()
# SUPER VERIFY that the INSERT about release was successfull
        sth = dbh.cursor();
        sth.execute("SELECT id FROM oss_releases WHERE oss_id="+str(comp_id)+" AND release_vers_name='"+version+"' LIMIT 1")
        row = sth.fetchone()
        sth.close()
        if row is None:
# INTEGRITY ERROR
            return None
        release_id = row[0]
    else:
        release_id = row[0]
    return release_id

#######################################################################

def     DDA_DBSmartInsert_Vulnerability(who,dbh,component_id,public_alias): 
# Test and sanitarize the Input data
    if((who is None) or (dbh is None) or (component_id is None) or (public_alias is None)):
        return None

    vuln_id = 0
# Search existing vulnerability records by the ALIAS
    sth = dbh.cursor()
    sth.execute("SELECT id FROM vulns WHERE public_alias_list LIKE '%$public_alias%' AND oss_id="+str(component_id)+" LIMIT 1");
    row = sth.fetchone()
    sth.close()
    if row is None:
# INSERT new vulnerability record if not found
        sth = dbh.cursor()
        sth.execute("INSERT INTO vulns (public_alias_list,oss_id,create_dt) VALUES ('"+public_alias+"',"+component_id+",NOW())");
        sth.close()
# SUPER CHECK
        sth = dbh.cursor()
        sth.execute("SELECT id FROM vulns WHERE public_alias_list LIKE '%$public_alias%' AND oss_id="+str(component_id)+" LIMIT 1");
        row = sth.fetchone()
        sth.close()
        if row is None:
# INTEGRITY ERROR
            return None
        vuln_id = row[0]
    else:
        vuln_id = row[0]
    return vuln_id

#######################################################################
"""
def     DDA_DBFullfillVulnInfoByVulnID {
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
"""

#######################################################################




#######################################################################
