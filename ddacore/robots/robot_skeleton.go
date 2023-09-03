package main

//////////////////////////////////////////////////////////////////
////////// ROBOT IMPORTS /////////////////////////////////////////
//////////////////////////////////////////////////////////////////

import (
        "time"
        "os"
//      "os/exec"
        "ddamodulesgolang"
)

//////////////////////////////////////////////////////////////////
////////// STANDARD ROBOT ////////////////////////////////////////
//////////////////////////////////////////////////////////////////

func    main() {

/////////// ROBOT SETTINGS ///////////////////////////////////////

        who:="GOLANG TEST";
        robot_status_name := "ROBOT_STATUS";
        robot_runcontrol_name := "ROBOT_STATUS";
        parsing_reciever_name := "PARSER_ROBOT";
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

        deepdiveautomation.DDAWriteToMainLog(who,"Starting...\n",nil);

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
        pstatus = "RUN";
        if(pstatus == "RUN") {
                if(timercounter >= jobtimer) {
                        timercounter = 0;
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [start job]",dbh);

//////////////////////////////////////////////////////////////////
///////////// ROBOT MAIN JOB /////////////////////////////////////
//////////////////////////////////////////////////////////////////







//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

                        deepdiveautomation.DDAUpdateFlag(who,parsing_reciever_name,"RUN",dbh);
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [job finished, parsing requested, next job scheduled]",dbh);
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
