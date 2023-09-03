import time
import deepdiveautomation
import re
import os
import dda_modulefor_db_interaction


who = "dda_robot_actualizer_relinfo"
ipc_relation_name = "status_"+who
runcontrol_name = "runcontrol_"+who
savedir = "/opt/datalake_dda/tmp/"
dwnldrdir = "/opt/datalake_dda/dwnldr_tmp/"

deepdiveautomation.DDAWriteToMainLog(who,"Starting robot");

dbh = deepdiveautomation.DDAConnectToDB(who)

#feedlog = deepdiveautomation.DDAConnectToFeedLOG(who)

sleeptimeout = 60
jobtimer = 10 

timercounter = jobtimer


####### SUBROUTINES #########################

def     ExtractEcosystemFromPurl(purl): 
    etalon_purl = re.compile('pkg:([a-zA-Z0-9]+)\/[a-zA-Z0-9\.\-\_\/]+')
    res = etalon_purl.match(purl)
    ecosystem = res.group(1)
    if ecosystem=="":
        ecosystem="-"
    return ecosystem

#############################################

def     ExtractOSSNameFromPurl(purl):
    purl = purl+"/"
    etalon_purl = re.compile('pkg:[a-zA-Z0-9]+\/([a-zA-Z0-9\.\-\_]+)\/[a-zA-Z0-9\.\-\_\/]*')
    res = etalon_purl.match(purl)
    ossname = res.group(1)
    return ossname


#############################################

def     WgetByURLStep1(url,filename):
    return os.system("wget -q -O "+savedir+filename+" "+url)

#############################################

def     SetDwnLdrStatus(conveyor_id,dwnldrstatus):
    sth = dbh.cursor()
    sth.execute("UPDATE factor_handler_conveyor SET dwnldr_status='"+dwnldrstatus+"' WHERE id="+str(conveyor_id))
    dbh.commit()
    sth.close()

#############################################

def     SaveURL1ToDB(conveyor_id,url1):
    sth = dbh.cursor()
    sth.execute("UPDATE factor_handler_conveyor SET dwnldr_link='"+url1+"' WHERE id="+str(conveyor_id))
    dbh.commit()
    sth.close()

#############################################

def     SaveWorkdirToDB(conveyor_id,workdirpath):
    sth = dbh.cursor()
    sth.execute("UPDATE factor_handler_conveyor SET workdirpath='"+workdirpath+"' WHERE id="+str(conveyor_id))
    dbh.commit()
    sth.close()

#############################################

def     DownloadFromPypi(purl,version,conveyor_id):
    ossname = ExtractOSSNameFromPurl(purl)
    url_step1 = "https://pypi.org/project/"+ossname+"/"+version+"/#files"
    deepdiveautomation.DDAWriteToDebugLog(who,"Pypi: "+purl+" "+version+"  "+url_step1)
    SaveURL1ToDB(conveyor_id,url_step1)
    res = WgetByURLStep1(url_step1,"pypi---"+ossname+"---"+version)
    if res == 0:
        grep_res = os.system("wget -q -O "+dwnldrdir+"pypi---"+ossname+"---"+version+".tar.gz `grep -m 1 -o \"http.*tar.gz\" "+savedir+"pypi---"+ossname+"---"+version+ "`")
        if grep_res == 0:
            tar_res = os.system("cd "+dwnldrdir+"; mkdir raw---pypi---"+ossname+"---"+version+";cd raw---pypi---"+ossname+"---"+version+";tar -xzf "+dwnldrdir+"pypi---"+ossname+"---"+version+".tar.gz")
            if tar_res == 0:
                workdirpath = dwnldrdir+"raw---pypi---"+ossname+"---"+version
                SaveWorkdirToDB(conveyor_id,workdirpath)
                SetDwnLdrStatus(conveyor_id,"Success")
            else:
                SetDwnLdrStatus(conveyor_id,"Failure-TAR")
        else:
            SetDwnLdrStatus(conveyor_id,"Failure-GREP")
    else:
        deepdiveautomation.DDAWriteToDebugLog(who,"Wget got 404 for url ["+url_step1+"]")
        SetDwnLdrStatus(conveyor_id,"Failure-SEARCH")

#############################################

def     DownloadFromNPM(purl,version,conveyor_id):
    ossname = ExtractOSSNameFromPurl(purl)
    url_step1 = "https://www.npmjs.com/package/"+ossname+"/v/"+version
    deepdiveautomation.DDAWriteToDebugLog(who,"NPM: "+purl+" "+version+"   "+url_step1)
    SaveURL1ToDB(conveyor_id,url_step1)
    res = WgetByURLStep1(url_step1,"npm---"+ossname+"---"+version)
    if res == 0:
        grep_res = os.system("wget -q -O "+dwnldrdir+"npm---"+ossname+"---"+version+".tar.gz `grep -m 1 -o -P Repository.*?http.+?' ' "+savedir+"npm---"+ossname+"---"+version+"| grep -o -P http.+[a-zA-Z0-9]`"+"/archive/refs/tags/v"+version+".tar.gz")
        if grep_res == 0:
            tar_res = os.system("cd "+dwnldrdir+"; mkdir raw---npm---"+ossname+"---"+version+";cd raw---npm---"+ossname+"---"+version+";tar -xzf "+dwnldrdir+"npm---"+ossname+"---"+version+".tar.gz")
            if tar_res == 0:
                workdirpath = dwnldrdir+"raw---npm---"+ossname+"---"+version
                SaveWorkdirToDB(conveyor_id,workdirpath)
                SetDwnLdrStatus(conveyor_id,"Success")
            else:
                SetDwnLdrStatus(conveyor_id,"Failure-TAR")
        else:
            SetDwnLdrStatus(conveyor_id,"Failure-GREP")
    else:
        deepdiveautomation.DDAWriteToDebugLog(who,"Wget got 404 for url ["+url_step1+"]")
        SetDwnLdrStatus(conveyor_id,"Failure-SEARCH")



#############################################

def     DownloadComponentByPurl(purl,version,conveyor_id):
    deepdiveautomation.DDAWriteToDebugLog(who,"Searching OSS by purl: ["+purl+"] vers: ["+version+"]")
    ecosystem = ExtractEcosystemFromPurl(purl)
    if ecosystem=='-':
        deepdiveautomation.DDAWriteToDebugLog(who,"Strange purl: ["+purl+"] - WARNING AND DO NOTHING")
    else :
        if ecosystem == 'pypi':
            DownloadFromPypi(purl,version,conveyor_id)
        elif ecosystem == 'npm':
            DownloadFromNPM(purl,version,conveyor_id)



#############################################

def     MainJobSubroutine():

    deepdiveautomation.DDAWriteToMainLog(who,"Starting MAIN JOB")

    sth = dbh.cursor()
    sth.execute("select purl_brief,version,id from factor_handler_conveyor where dwnldr_status='ToDo' order by id asc")

    index = 0
    while 1:
        row = sth.fetchone()
        if row is None:
            break
        DownloadComponentByPurl(row[0],row[1],row[2])
        index = index+1
    sth.close()

    deepdiveautomation.DDAWriteToMainLog(who,"Finished MAIN JOB. HandledCount=["+str(index)+"]")

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
