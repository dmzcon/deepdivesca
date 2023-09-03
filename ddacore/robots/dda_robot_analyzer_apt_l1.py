import time
import deepdiveautomation
import re
import os


who = "dda_robot_analyzer_apt_l1"
ipc_relation_name = "status_"+who
runcontrol_name = "runcontrol_"+who
savedir = "/opt/datalake_dda/tmp/"
dwnldrdir = "/opt/datalake_dda/dwnldr_tmp/"

yararulesdir = "/opt/dda/ddacore/checkers/yararulesets/apt"

deepdiveautomation.DDAWriteToMainLog(who,"Starting robot");

dbh = deepdiveautomation.DDAConnectToDB(who)

#feedlog = deepdiveautomation.DDAConnectToFeedLOG(who)

sleeptimeout = 60
jobtimer = 30 

timercounter = jobtimer


####### SUBROUTINES #########################


def UpdateAnalyzerStatus(conveyor_id,newstatus):
    sth = dbh.cursor()
    sth.execute("UPDATE factor_handler_conveyor SET status_"+who+"='"+newstatus+"' WHERE id="+str(conveyor_id))
    sth.close()


#############################################

def SaveScoreForConveyor(conveyor_id,newscore):
    newscore = newscore.rstrip()
#    print("["+newscore+"]")
    sth = dbh.cursor()
    sth.execute("UPDATE factor_handler_conveyor SET score_"+who+"='"+newscore+"' WHERE id="+str(conveyor_id))
    sth.close()


#############################################

def YARA_AnalyzeJobForWorkdir(conveyor_id,workdirpath):
    UpdateAnalyzerStatus(conveyor_id,'ANALYZE STARTED') 
    for root,dirs,files in os.walk(yararulesdir):
        for rulename in files:
            ruleresult = os.popen("yara -r "+yararulesdir+"/"+rulename+" "+workdirpath).read()
            if ruleresult is not None and ruleresult != "":
                rulescore = os.popen("grep -m 1 -o -P dda_score.*?$ "+yararulesdir+"/"+rulename).read()
                SaveScoreForConveyor(conveyor_id,rulename+": "+rulescore)
                UpdateAnalyzerStatus(conveyor_id,'ANALYZE IN PROGRES')

    UpdateAnalyzerStatus(conveyor_id,'Done') 



#############################################

def     MainJobSubroutine():

    deepdiveautomation.DDAWriteToMainLog(who,"Starting MAIN JOB")

    sth = dbh.cursor()
    sth.execute("select id,workdirpath from factor_handler_conveyor where dwnldr_status='Success' and status_"+who+"='ToDo' order by id asc")

    index = 0
    while 1:
        row = sth.fetchone()
        if row is None:
            break
        YARA_AnalyzeJobForWorkdir(row[0],row[1])
        index = index+1
    sth.close()

    deepdiveautomation.DDAWriteToMainLog(who,"Finished MAIN JOB. AnalyzedCount=["+str(index)+"]")

#############################################



#############################################
####### STANDARD ROBOT ######################
#############################################

while   True:
    gstatus = deepdiveautomation.DDAGetGeneralStatus(who,dbh)
    if gstatus[0]!='OK':
        deepdiveautomation.DDAWriteToMainLog(who,"G-Exiting...")
        deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'G-Off')
        exit(0)
    pstatus = deepdiveautomation.DDAGetPersonalStatus(who,dbh,runcontrol_name)
    if pstatus[0]=='STOP':
        deepdiveautomation.DDAWriteToMainLog(who,"P-Exiting...")
        deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'P-Off')
        exit(0)
    if pstatus[0]=='RUN':
        if timercounter >= jobtimer:
            timercounter = 0
            deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'Running [start job]')

#############################################
######### ROBOT MAIN JOB ####################
#############################################

            MainJobSubroutine()

#############################################
######### ROBOT MAIN JOB FINISHED ###########
#############################################

            deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'Running [current job finished, next job scheduled]')
        else:
            deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'Running [next job starttimer='+str(timercounter)+"/"+str(jobtimer)+"]")
    if pstatus[0]=='PAUSE':
        deepdiveautomation.DDAUpdateFlag(who,dbh,ipc_relation_name,'Suspended, do nothing, waiting status change')

    timercounter=timercounter+1
    time.sleep(sleeptimeout)
# END OF WHILE LOOP

dbh.close()
