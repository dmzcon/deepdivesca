import time
import deepdiveautomation


who = "dda_robot_factor_logs_handler"
ipc_relation_name = "status_"+who
runcontrol_name = "runcontrol_"+who

deepdiveautomation.DDAWriteToMainLog(who,"Starting robot");

dbh = deepdiveautomation.DDAConnectToDB(who)

feedlog = deepdiveautomation.DDAConnectToFeedLOG(who)

sleeptimeout = 60
jobtimer = 235 

timercounter = jobtimer


####### SUBROUTINES #########################

def     AnalyzePurlStringRecord(purl,version):
    deepdiveautomation.DDAWriteToDebugLog(who,"Analyze purl record: ["+purl+"] Version: ["+version+"]")
    sth = dbh.cursor()
    sth.execute("select id from factor_handler_conveyor where purl_brief='"+purl+"' and version='"+version+"'")
    res = sth.fetchone()
    if res is None:
        deepdiveautomation.DDAWriteToDebugLog(who,"No record found, inserting...")
        sth_insert = dbh.cursor()
        sth_insert.execute("insert into factor_handler_conveyor (purl_brief,version,record_create_dt) values ('"+purl+"','"+version+"',NOW())")
        dbh.commit()
        sth_insert.close()
    else:
        deepdiveautomation.DDAWriteToDebugLog(who,"Found record_id=["+str(res[0])+"]")
    sth.close()



#############################################

def     MainJobSubroutine():

    deepdiveautomation.DDAWriteToMainLog(who,"Starting MAIN JOB")

    sth = feedlog.cursor()
    sth.execute("select purl,version,count(purl) from log.requests where (event_time + '240 minute') > now() group by purl,version order by count(purl) desc")

    index = 0
    while 1:
        row = sth.fetchone()
        if row is None:
            break
        AnalyzePurlStringRecord(row[0],row[1])
        index = index+1
    sth.close()

    deepdiveautomation.DDAWriteToMainLog(who,"Finished MAIN JOB. RecordsCount=["+str(index)+"]")

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
