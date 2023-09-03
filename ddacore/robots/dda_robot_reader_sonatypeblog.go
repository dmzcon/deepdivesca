package main

//////////////////////////////////////////////////////////////////
////////// ROBOT IMPORTS /////////////////////////////////////////
//////////////////////////////////////////////////////////////////

import (
        "time"
        "os"
        "fmt"
        "os/exec"
        "ddamodulesgolang"
)

//////////////////////////////////////////////////////////////////
////////// STANDARD ROBOT ////////////////////////////////////////
//////////////////////////////////////////////////////////////////

func    main() {

/////////// ROBOT SETTINGS ///////////////////////////////////////

        who:="dda_robot_reader_sonatypeblog";
        robot_status_name := "status_dda_robot_reader_sonatypeblog";
        robot_runcontrol_name := "runcontrol_dda_robot_reader_sonatypeblog";
        parsing_reciever_name := "runcontrol_dda_robot_parser_sonatypeblog";
        var (
                sleeptimer_unit time.Duration
        );
        sleeptimer_unit = 60;
        jobtimer := 60*12;

//////////////////////////////////////////////////////////////////
/////////// ROBOT INITIALIZATION /////////////////////////////////

        dbh:=deepdiveautomation.DDAConnectToDB(who);
        defer dbh.Close();
        timercounter := jobtimer;

        monthname := map[time.Month]string{
                1: "jan",
                2: "febr",
                3: "march",
                4: "apr",
                5: "may",
                6: "june",
                7: "july",
                8: "aug",
                9: "sept",
                10: "oct",
                11: "nov",
                12: "dec",
        }
        datename := map[int]string{
                1: "01",
                2: "02",
                3: "03",
                4: "04",
                5: "05",
                6: "06",
                7: "07",
                8: "08",
                9: "09",
                10: "10",
                11: "11",
                12: "12",
                13: "13",
                14: "14",
                15: "15",
                16: "16",
                17: "17",
                18: "18",
                19: "19",
                20: "20",
                21: "21",
                22: "22",
                23: "23",
                24: "24",
                25: "25",
                26: "26",
                27: "27",
                28: "28",
                29: "29",
                30: "30",
                31: "31",
        }

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

        deepdiveautomation.DDAWriteToMainLog(who,"Started SonatypeBlog synchro robot. First synchro download is scheduled and will start in 3 minutes",nil)
        time.Sleep(180*time.Second)

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

//fmt.Println("%d %d %s %s\n",timercounter,jobtimer,gstatus,pstatus);

        if(pstatus == "RUN") {
                if(timercounter >= jobtimer) {
                        timercounter = 0;
                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [start job]",dbh);

//////////////////////////////////////////////////////////////////
///////////// ROBOT MAIN JOB /////////////////////////////////////
//////////////////////////////////////////////////////////////////

                curtime := time.Now()
                mon := curtime.Month()
                date := curtime.Day()
                newurl := fmt.Sprintf("https://blog.sonatype.com/this-week-in-malware-%s-%s-22/", monthname[mon],datename[date])
                deepdiveautomation.DDAWriteToDebugLog(who,"Visiting Sonatype's Blog. Looking for new posts\n Trying URLs:",nil)
                deepdiveautomation.DDAWriteToDebugLog(who,newurl,nil)

                cmd := exec.Command("/bin/wget", "-O", "/opt/datalake_dda/workdir/vuln_info_parsing/sonatypeblog/rawpage", newurl)
                err := cmd.Run();

                if err != nil {
                        if(date<10) {
                                newurl_alt := fmt.Sprintf("https://blog.sonatype.com/this-week-in-malware-%s-%d-22/", monthname[mon],date)
                                deepdiveautomation.DDAWriteToDebugLog(who,newurl_alt,nil)
                                cmd2 := exec.Command("/bin/wget", "-O", "/opt/datalake_dda/workdir/vuln_info_parsing/sonatypeblog/rawpage", newurl_alt)
                                err2 := cmd2.Run();
                                if err2 != nil {
                                        deepdiveautomation.DDAWriteToMainLog(who,"SonatypeBlog WGET failure for 2nd url too (new post not found)", err2)
                                } else {
                                        deepdiveautomation.DDAWriteToMainLog(who,"SonatypeBlog synchro OK for 2nd URL. Saved at /opt/datalake_dda/workdir/vuln_info_parsing/sonatypeblog/rawpage",nil)
                                        deepdiveautomation.DDAUpdateFlag(who,parsing_reciever_name,"RUN",dbh);
                                        timercounter = timercounter-(60*36);
                                }
                        } else {
                                deepdiveautomation.DDAWriteToMainLog(who,"SonatypeBlog WGET failure (new post not found)", err)
                        }
                } else {
                        deepdiveautomation.DDAWriteToMainLog(who,"SonatypeBlog synchro OK. Saved at /opt/datalake_dda/workdir/vuln_info_parsing/sonatypeblog/rawpage",nil)
                        deepdiveautomation.DDAUpdateFlag(who,parsing_reciever_name,"RUN",dbh);
                        timercounter = timercounter-(60*36);

                }



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


                        deepdiveautomation.DDAUpdateFlag(who,robot_status_name,"Running [job finished, next job scheduled]",dbh);
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
