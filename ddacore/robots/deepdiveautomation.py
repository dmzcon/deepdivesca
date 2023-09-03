import  psycopg2

#######################################################################
############# Deepdiveautomation PYTHON-functions #####################
#######################################################################



#######################################################################

def DDAWriteToDebugLog(who,debugmessage):
    debugfile = open('/opt/dda/logs/debuglog','a+')
    debugfile.write('['+who+']:'+debugmessage+'\n')
    debugfile.close()
    return;    

    
#######################################################################

def DDAWriteToMainLog(who,logmessage):
    logfile = open('/opt/dda/logs/errorlog','a+')
    logfile.write('['+who+']:'+logmessage+'\n')
    logfile.close()
    return;    




#######################################################################

def DDAConnectToDB(who):
    db = {}
    db["host"] = "localhost"
    db["database"] = "   "
    db["user"] = "   "
    db["password"] = "   "
    dbh = psycopg2.connect(**db)
    sth = dbh.cursor()
    sth.execute('SELECT version()')
    res = sth.fetchone()
    DDAWriteToMainLog(who,'['+who+'] connected to DeepDive DB: '+str(res[0]))
    sth.close()
    return  dbh   


#######################################################################

def DDAConnectToFeedLOG(who):
    db = {}
    db["host"] = "   "
    db["port"] = "   "
    db["database"] = "   "
    db["user"] = "   "
    db["password"] = "   "
    dbh = psycopg2.connect(**db)
    sth = dbh.cursor()
    sth.execute('SELECT version()')
    res = sth.fetchone()
    DDAWriteToMainLog(who,'['+who+'] connected to FeedLOG: '+str(res[0]))
    sth.execute("select count(id) from log.requests where (event_time + '240 minute') > now()")
    res = sth.fetchone()
    DDAWriteToDebugLog(who,'['+who+'] FeedLOG RequestsCount for last 4 hours:'+str(res[0]))
    sth.close()
    return  dbh   


#######################################################################

def DDAGetGeneralStatus(who,dbh):
    sth = dbh.cursor()
    sth.execute("SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='status_general' LIMIT 1")
    status = sth.fetchone()
    sth.close()
    return status


#######################################################################

def DDAGetPersonalStatus(who,dbh,runcontrol_name):
    sth = dbh.cursor()
    sth.execute("SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='"+runcontrol_name+"' LIMIT 1")
    status = sth.fetchone()
    sth.close()
    return status




#######################################################################

def DDAUpdateFlag(who,dbh,relname,newval):
    DDAWriteToDebugLog(who,"DDAUpdateFlag performed query: ["+relname+"] => ["+newval+"]")
    sth = dbh.cursor()
    sth.execute("UPDATE intersystems_interconnection SET relation_flag='"+newval+"',lastchange_dt=NOW() WHERE relation_name='"+relname+"'")
    dbh.commit()
    sth.close()
    return


#######################################################################






#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
