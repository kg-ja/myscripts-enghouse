#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
theIPaddressVM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
theIPaddressHW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


LOG_FILE=/tmp/SBC_BNETSCS_RAM USAGE-$HOST_NAME.log


PID=$(pgrep -f "^/usr/lib64/ld-linux.* /opt/bnet/bin/bnetscs")

if [ -z "$PID" ]; then
  echo "bnetscs not running" >> $LOG_FILE
  exit 1
fi

while true; do
  if ps -p "$PID" > /dev/null 2>&1; then
    printf "%s " "$(date '+%F %T')" >> $LOG_FILE
    ps -p "$PID" -o rss= >> $LOG_FILE
  else
    printf "%s PID %s not running\n" "$(date '+%F %T')" "$PID" >> $LOG_FILE
    exit 1
  fi
  sleep 60
done


echo | tee -a "$LOG_FILE"
 

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SBC_BNETSCS_RAM USAGE-$HOST_NAME-$theSerial-$theIPaddressVM-$theIPaddressHW-$(date +"%Y_%m_%d_%I_%M_%p").log

echo "This script has completed, please check /tmp folder for SBC_LOG_INFO-* log to send to support" 

exit 0;