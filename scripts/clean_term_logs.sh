#!/bin/bash

RAWLOGDIR=~/tmp
NEWLOGDIR=~/logs/term

## first, find all unprocessed logs
#for RAWLOG in $( cd ~/logs/term/raw ls ); do
for RAWLOG in $( cd ~/tmp; ls $(hostname)_*.rlog ); do

  ## for each log found, check the PID to see if it's still running
  IFS=_ read HOSTNAME RAW_PID TIMESTAMP <<< ${RAWLOG} #file format is hostname_pid_date-time.log
  TIMESTAMP="${TIMESTAMP%.*}"
  IFS=- read YEAR MON JUNK <<< ${TIMESTAMP}

  ## only proceed if the term process is NOT runnning
  ## kill -0 checks if we can signgal a proc, it doesn't actually signal it
  if ! kill -0 ${RAW_PID} &> /dev/null; then
    # PID is NOT running so process the log
    LOGPATH="${NEWLOGDIR}/${YEAR}/${MON}"
    NEWLOGFILE="${HOSTNAME}_${TIMESTAMP}.log"
    perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' ${RAWLOGDIR}/${RAWLOG} | col -b > ${LOGPATH}/${NEWLOGFILE}
  else
    echo "pid $RAW_PID is running..."
  fi
done
