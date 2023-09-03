package deepdiveautomation

///////////////////////////////////////////////////////////////////////////////////

import (
        "fmt"
        "time"
        "os"
        "database/sql"
     _ "github.com/lib/pq"
)

///////////////////////////////////////////////////////////////////////////////////

const (
    host     = "localhost"
    port     = 5432
    user     = "   "
    password = "   "
    dbname   = "   "
)

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////


func    DDAWriteToDebugLog(who string, mess string, errcode error) {
        curtime := time.Now()
        f_errorlogfile, err := os.OpenFile("/opt/dda/logs/debuglog", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
        if err != nil {
                return;
        }
        if errcode != nil {
                i_message := fmt.Sprintf("%s: [%s] %s: %v\n", curtime.String(),who,mess,errcode)
                f_errorlogfile.Write([]byte(i_message))
        } else {
                i_message := fmt.Sprintf("%s: [%s] %s\n", curtime.String(),who,mess)
                f_errorlogfile.Write([]byte(i_message))
        }
        f_errorlogfile.Close()
        return;
}

///////////////////////////////////////////////////////////////////////////////////


func    DDAWriteToMainLog(who string, mess string, errcode error) {
        curtime := time.Now()
        f_errorlogfile, err := os.OpenFile("/opt/dda/logs/errorlog", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
        if err != nil {
                return;
        }
        if errcode != nil {
                i_message := fmt.Sprintf("%s: [%s] %s: %v\n", curtime.String(),who,mess,errcode)
                f_errorlogfile.Write([]byte(i_message))
        } else {
                i_message := fmt.Sprintf("%s: [%s] %s\n", curtime.String(),who,mess)
                f_errorlogfile.Write([]byte(i_message))
        }
        f_errorlogfile.Close()
        return;
}

///////////////////////////////////////////////////////////////////////////////////

func    DDAConnectToDB(who string) *sql.DB {
        psqlconn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)
        dbh, err := sql.Open("postgres", psqlconn)
        if err!=nil {
                DDAWriteToMainLog(who,"DB-connection failure", err)
                return nil;
        }
        err = dbh.Ping()
        if err!=nil {
                DDAWriteToMainLog(who,"DB-ping failure", err)
                return nil;
        } else {
                return dbh;
        }
}

///////////////////////////////////////////////////////////////////////////////////

func    DDAGetGeneralStatus(who string, dbh *sql.DB) string {
        if(dbh == nil) {
                DDAWriteToMainLog(who,"DDAGetGeneralStatus DB-connection failure", nil)
                return "";
        }
        query := "SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='status_general' LIMIT 1";
        rows, err := dbh.Query(query);
        if err!=nil {
                DDAWriteToMainLog(who,"DDAGetGeneralStatus SELECT-QUERY failure", nil)
                return "";
        }
        defer rows.Close()
        var (
                general_status string
        )
        for rows.Next() {
                rows.Scan(&general_status);
                return general_status;
        }

        return "";
}

///////////////////////////////////////////////////////////////////////////////////

func    DDAGetPersonalStatus(who string,runcontrol_name string,dbh *sql.DB) string {
        if(dbh == nil) {
                DDAWriteToMainLog(who,"DDAGetPersonalStatus DB-connection failure", nil)
                return "";
        }
        query := fmt.Sprintf("SELECT relation_flag FROM intersystems_interconnection WHERE relation_name='%s' LIMIT 1",runcontrol_name);
        rows, err := dbh.Query(query);
        if err!=nil {
                DDAWriteToMainLog(who,"DDAGetPersonalStatus SELECT-QUERY failure", nil)
                return "";
        }
        defer rows.Close()
        var (
                personal_status string
        )
        for rows.Next() {
                rows.Scan(&personal_status);
                return personal_status;
        }

        return "";
}

///////////////////////////////////////////////////////////////////////////////////

func    DDAUpdateFlag(who string,relname string,newval string,dbh *sql.DB)  {
        if(dbh == nil) {
                DDAWriteToMainLog(who,"DDAUpdateFlag DB-connection failure", nil)
                return;
        }

        query := fmt.Sprintf("UPDATE intersystems_interconnection SET relation_flag='%s',lastchange_dt=NOW() WHERE relation_name='%s'",newval,relname);
        result,err := dbh.Exec(query);
        if err!=nil {
                DDAWriteToMainLog(who,"DDAUpdateFlag UPDATE-QUERY failure", nil)
        } else {
                resstr := fmt.Sprintf("DDAUpdateFlag performed query: [%s] => [%s]",relname,newval);
                DDAWriteToDebugLog(who,resstr,nil);
                resstr = fmt.Sprintf("[%s]",result);
        }

        return;
}

///////////////////////////////////////////////////////////////////////////////////









///////////////////////////////////////////////////////////////////////////////////






///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
