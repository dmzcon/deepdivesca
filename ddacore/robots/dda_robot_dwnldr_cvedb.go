package main

//////////////////////////////////////////////////////////////////
////////// ROBOT IMPORTS /////////////////////////////////////////
//////////////////////////////////////////////////////////////////

import (
        "time"
        "os"
        "os/exec"
        "fmt"
        "ddamodulesgolang"
)

//////////////////////////////////////////////////////////////////
////////// STANDARD ROBOT ////////////////////////////////////////
//////////////////////////////////////////////////////////////////

func    main() {

/////////// ROBOT SETTINGS ///////////////////////////////////////

        who:="dda_robot_dwnldr_cvedb";
        robot_status_name := "status_dda_robot_dwnldr_cvedb";
        robot_runcontrol_name := "runcontrol_dda_robot_dwnldr_cvedb";
        parsing_reciever_name := "runcontrol_dda_robot_parser_cvedb";
        var (
                sleeptimer_unit time.Duration
        );
        sleeptimer_unit = 60;
        jobtimer := 60*24;

//////////////////////////////////////////////////////////////////
/////////// ROBOT INITIALIZATION /////////////////////////////////

        dbh:=deepdiveautomation.DDAConnectToDB(who);
        defer dbh.Close();
        timercounter := jobtimer;

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

        deepdiveautomation.DDAWriteToMainLog(who,"Started CVE.ORG DB synchro robot. First synchro download is scheduled and will start in 20 minutes",nil)
        time.Sleep(1200*time.Second)

for {

        gstatus := deepdiveautomation.DDAGetGeneralStatus(who, dbh);
        if(gstatus != "OK") {
                deepdiveautomation.DDAWriteToMainLog(who,"G-Exiting...\n",nil);
                deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"G-Off",dbh);
                os.Exit(0);
        }
        pstatus := deepdiveautomation.DDAGetPersonalStatus(who,robot_runcontrol_name, dbh);
        if(pstatus == "STOP") {
                deepdiveautomation.DDAWriteToMainLog(who,"P-Exiting...\n",nil);
                deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"P-Off",dbh);
                os.Exit(0);
        }
        if(pstatus == "RUN") {
                if(timercounter >= jobtimer) {
                        timercounter = 0;
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [start job]",dbh);

//////////////////////////////////////////////////////////////////
///////////// ROBOT MAIN JOB /////////////////////////////////////
//////////////////////////////////////////////////////////////////

                        deepdiveautomation.DDAWriteToMainLog(who,"Starting CVE.ORG DB download job",nil)

                        cmd := exec.Command("/bin/wget", "-O", "/opt/datalake_dda/workdir/vuln_info_parsing/cve-downloads/cvedb.xml", "https://cve.mitre.org/data/downloads/allitems.xml")
                        err := cmd.Run();

                        if err != nil {
                                deepdiveautomation.DDAWriteToMainLog(who,"WGET error", err)
                        } else {
                                deepdiveautomation.DDAWriteToMainLog(who,"Finished CVE.ORG DB download. Saved at /opt/datalake_dda/workdir/vuln_info_parsing/cve-downloads/allitems.xml",nil)
                        }



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

                        deepdiveautomation.DDAUpdateFlag(who,parsing_reciever_name,"RUN",dbh);
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [job finished, parsing requested, next job scheduled]",dbh);
                } else {
                        tmpmess := fmt.Sprintf("Running [next job starttimer=%d/%d]\n",timercounter,jobtimer);
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,tmpmess,dbh);
                }

        }
        if(pstatus == "PAUSE") {
                deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Suspended, do nothing, waiting for status change",dbh);
                timercounter = jobtimer;
        }
        timercounter++;
        time.Sleep(sleeptimer_unit*time.Second);

} // WHILE FINISH

}
///////////////////////////////////////////////////////////////////
