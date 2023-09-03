package main

//////////////////////////////////////////////////////////////////
////////// ROBOT IMPORTS /////////////////////////////////////////
//////////////////////////////////////////////////////////////////

import (
        "time"
        "os"
        "os/exec"
        "ddamodulesgolang"
        "fmt"
)

//////////////////////////////////////////////////////////////////
////////// STANDARD ROBOT ////////////////////////////////////////
//////////////////////////////////////////////////////////////////

func    main() {

/////////// ROBOT SETTINGS ///////////////////////////////////////

        who:="dda_robot_dwnldr_ghadb";
        robot_status_name := "status_dda_robot_dwnldr_ghadb";
        robot_runcontrol_name := "runcontrol_dda_robot_dwnldr_ghadb";
        parsing_reciever_name := "runcontrol_dda_robot_parser_ghadb";
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

        deepdiveautomation.DDAWriteToMainLog(who,"Started GHA synchro robot. First synchro download is scheduled and will start in 40 minutes",nil);
        time.Sleep(2400*time.Second)

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


                        deepdiveautomation.DDAWriteToMainLog(who,"Start GHABASE git-clone job",nil)

//                      cmd1 := exec.Command("/bin/rm", "-rf", "/opt/datalake_dda/workdir/vuln_info_parsing/ghadb/fromgithub/advisory-database")
//                      err := cmd1.Run();

//                      cmd2 := exec.Command("/bin/git", "-C", "/opt/datalake_dda/workdir/vuln_info_parsing/ghadb/fromgithub/", "clone", "https://github.com/github/advisory-database.git")
                        cmd2 := exec.Command("/bin/git", "-C", "/opt/datalake_dda/workdir/vuln_info_parsing/ghadb/fromgithub/advisory-database/", "pull")
                        err := cmd2.Run();

                        if err != nil {
                                deepdiveautomation.DDAWriteToMainLog(who,"GIT CLONE FAILURE", err)
                        } else {
                                deepdiveautomation.DDAWriteToMainLog(who,"GitHub Advisory synchro OK. Saved at /opt/datalake_dda/workdir/vuln_info_parsing/ghadb/fromgithub/advisory-database",nil)
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
