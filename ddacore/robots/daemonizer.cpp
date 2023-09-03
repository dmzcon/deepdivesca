#include  <stdio.h>
#include  <unistd.h>
#include  <stdlib.h>
#include  <sys/time.h>
#include  <time.h>
#include  <termios.h>
#include  <errno.h>
#include  <fcntl.h>
#include <pthread.h>

#define IS_DAEMON               1

/////////////////////////

void    LogTheMessage(unsigned int d1,unsigned int d2,char *message) {
FILE *f;
time_t tp;
struct tm *curtime;
struct timeval  timeval;
struct timezone tzp;
int mday,mon,hour,min;
f = fopen("/opt/dda/logs/errorlog","a");
if(f) {
        gettimeofday(&timeval,&tzp);
        tp = timeval.tv_sec;
        curtime=localtime(&tp);
        hour = curtime->tm_hour;
        min = curtime->tm_min;
        mday = curtime->tm_mday;
        mon = curtime->tm_mon;
        mon++;
        fprintf(f,"%d-%d_%d:%d - [%d] - [DAEMONIZER] -\t%s - %d\n",mon,mday,hour,min,d2,message,d1);
        fclose(f);
}
}

/////////////////////////

int     daemonize(void) {
  char *ptty0;
  char *ptty1;
  char *ptty2;
  int fd;
  if (((ptty0 = ttyname(0)) == NULL) || ((ptty1 = ttyname(1)) == NULL) ||
      ((ptty2 = ttyname(2)) == NULL))
    return -1;

  if (fork() != 0)
    return -1;
  close(0);
  close(1);
  close(2);
  setsid();
if ((fd = open("/dev/null", O_RDONLY)) == -1)  {
        LogTheMessage(1,0,"Daemonize FAILTURE");
  return -1;
}
if (dup2(fd, 0) == -1)  {
        LogTheMessage(2,0,"Daemonize FAILTURE");
  return -1;
}
if ((fd = open(ptty1, O_WRONLY)) == -1)  {
        LogTheMessage(3,0,"Daemonize FAILTURE");
  return -1;
}
if (dup2(fd, 1) == -1)  {
        LogTheMessage(4,0,"Daemonize FAILTURE");
  return -1;
}
if (close(fd) == -1)  {
        LogTheMessage(5,0,"Daemonize FAILTURE");
  return -1;
}
if ((fd = open(ptty2, O_WRONLY)) == -1)  {
        LogTheMessage(6,0,"Daemonize FAILTURE");
  return -1;
}
if (dup2(fd, 2) == -1)  {
        LogTheMessage(7,0,"Daemonize FAILTURE");
  return -1;
}
if (close(fd) == -1)  {
        LogTheMessage(8,0,"Daemonize FAILTURE");
  return -1;
}

return 0;
}

/////////////////////////

int main (void) {

#ifdef  IS_DAEMON
        if(daemonize()!=0) return 1;
#endif

        LogTheMessage(0,0,"LAUNCHING ALL ROBOTS:");

        if (fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_dwnldr_cved");
                system("go run /opt/dda/ddacore/robots/dda_robot_dwnldr_cvedb.go");
        } else if(fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_dwnldr_ghadb");
                system("go run /opt/dda/ddacore/robots/dda_robot_dwnldr_ghadb.go");
        } else if(fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_reader_sonatypeblog");
                system("go run /opt/dda/ddacore/robots/dda_robot_reader_sonatypeblog.go");
        } else if(fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_parser_cvedb");
                system("/opt/dda/ddacore/robots/dda_robot_parser_cvedb.pl");
        } else if(fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_parser_ghadb");
                system("/opt/dda/ddacore/robots/dda_robot_parser_ghadb.pl");
        } else if(fork() == 0) {
                LogTheMessage(0,0,"LAUNCHED dda_robot_parser_sonatypeblog");
                system("/opt/dda/ddacore/robots/dda_robot_parser_sonatypeblog.pl");
        }


while(1) {
        sleep(10000);
}

return 0;
}
