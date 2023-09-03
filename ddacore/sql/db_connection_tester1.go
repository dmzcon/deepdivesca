package main
import (
        "fmt"
        "time"
    //    "net/http"
       "os"
    //    "io/ioutil"
     "database/sql"
     _ "github.com/lib/pq"
)

///////////////////////////////

const (
    host     = "localhost"
    port     = 5432
    user     = "   "
    password = "   "
    dbname   = "   "
)


///////////////////////////////

func    dda_logger(mess string, errcode error) {
        curtime := time.Now()
        f_errorlogfile, err := os.OpenFile("/opt/dda/logs/errorlog", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
        if err != nil {
                os.Exit(1)
        }
        if errcode != nil {
                i_message := fmt.Sprintf("%s: %s: %v\n", curtime.String(),mess,errcode)
                f_errorlogfile.Write([]byte(i_message))
        } else {
                i_message := fmt.Sprintf("%s: %s\n", curtime.String(),mess)
                f_errorlogfile.Write([]byte(i_message))
        }
        f_errorlogfile.Close()
}


///////////////////////////////

func    main() {
        var relation_flag string

        dda_logger("Testing DB-connection",nil)

        psqlconn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)
         
        // open database
        db, err := sql.Open("postgres", psqlconn)
        if err!=nil {
                dda_logger("DB-connection failure", err)
                os.Exit(1)
        }

        err = db.Ping()
        if err!=nil {
                dda_logger("DB-ping failure", err)
                os.Exit(1)
        } else {
                dda_logger("DB-ping success", nil)
        }

        rows, err := db.Query("select relation_flag from intersystems_interconnection where relation_name='status_general' limit 1")
        if err!=nil {
                dda_logger("DB-query failure", err)
                os.Exit(1)
        }
        rows.Next()
        err = rows.Scan(&relation_flag)
        if err!=nil {
                dda_logger("DB-scan failure", err)
                os.Exit(1)
        }

        i_message := fmt.Sprintf("System status: %s", relation_flag)
        dda_logger(i_message,nil)

        defer db.Close()
}
