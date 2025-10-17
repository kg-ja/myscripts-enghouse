#!/bin/bash

# kill_sipp.sh - Kill all SIPp processes daily

# create crontab 0 0 * * * /home/sysadmin/kill_sipp


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)

LOGFILE="/tmp/kill_sipp.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)





kill_sipp() {
clear

echo "Current DATE: $DATE]" >> "$LOGFILE"

echo "The Interface name of this system is $iface " >> "$LOGFILE"

echo "The IP address of this system is $theIPaddress " >> "$LOGFILE"

echo "The Hostname of this system is $HOST_NAME " >> "$LOGFILE"

echo "[$DATE] Checking for SIPp processes..." >> "$LOGFILE"

# Find all running SIPp processes and kill them
PIDS=$(pgrep -f sipp | xargs)

if [ -n "$PIDS" ]; then
    echo "[$DATE] Found SIPp PIDs: $PIDS. Killing..." >> "$LOGFILE"
    kill -9 $PIDS
    echo "[$DATE] SIPp processes killed." >> "$LOGFILE"
else
    echo "[$DATE] No SIPp processes running." >> "$LOGFILE"
fi

}






# main menu

kill_sipp


echo "The script has completed ..."  >> "$LOGFILE"


exit 0;