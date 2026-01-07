#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)

DATE=$(date '+%Y-%m-%d %H:%M:%S')

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


DIR=/root/sipp-3.7.3/


uacserverIP=10.61.13.254
uacserverPort=5060

uassserverIP=10.61.13.183
uassserverPort=5060

SBC1UACIP=10.61.13.202
SBC2UACIP=10.61.13.204


SBC1UASIP=10.61.13.160
SBC2UASIP=10.61.13.172

LOG_FILE=/tmp/SIPp_CALLS-$HOST_NAME.log


kill_sipp() {


echo "[$DATE] Checking for SIPp processes..." >> $LOG_FILE

# Find all running SIPp processes and kill them
PIDS=$(pgrep -f sipp | xargs)

if [ -n "$PIDS" ]; then
    echo "[$DATE] Found SIPp PIDs: $PIDS. Killing..." >> $LOG_FILE
    kill -9 $PIDS
    echo "[$DATE] SIPp processes killed." >> $LOG_FILE
else
    echo "[$DATE] No SIPp processes running." >> $LOG_FILE
fi

}


uac_to_uas_call() {

cd $DIR

# Launch script in background
./sipp -sf uas.xml -i $uassserverIP -p $uassserverPort &

# Get its PID for command above
PID=$!

echo "===The-PID-for-SIpp-is-$PID ===" >> $LOG_FILE


echo "===SIPp-CALLING-SBC28-$SBC1UACIP===" >> $LOG_FILE

./sipp -i $uacserverIP -p $uacserverPort -sf uac_usercalls.xml -nr -m 10 -inf usercalls200.csv -d 55000 -l 15 $SBC1UACIP:5060


sleep 5

./sipp -i $uacserverIP -p $uacserverPort -sf uac_usercalls-emergency.xml -nr -m 8 -inf usercalls13-emergency.csv -d 10000 -l 5 $SBC1UACIP:5060


sleep 5


echo "===SIPp-CALLING-SBC53-$SBC2UACIP===" >> $LOG_FILE

./sipp -i $uacserverIP -p $uacserverPort -sf uac_usercalls.xml -nr -m 5 -inf usercalls200.csv -d 75000 -l 15 $SBC2UACIP:5060


sleep 5

./sipp -i $uacserverIP -p $uacserverPort -sf uac_usercalls-emergency.xml -nr -m 8 -inf usercalls13-emergency.csv -d 10000 -l 5 $SBC2UACIP:5060


sleep 5


echo "===Killing-The-PID-for-SIpp-$PID ===" >> $LOG_FILE
kill -s SIGKILL $PID

# not used anymore
#kill -9 $(ps -ef | grep [s]ipp | awk '{print $2}')

echo "==========================SIPp-CALL-ENDED-$CURRENT_TIMESTAMP===================================" >> $LOG_FILE
}

uas_to_uac_call() {

cd $DIR

# Launch script in background
./sipp -sf uas.xml -i $uacserverIP -p 5060 &

# Get its PID for command above
PID=$!

echo "===The-PID-for-SIpp-is-$PID ===" >> $LOG_FILE


echo "===SIPp-CALLING-SBC28-$SBC1UASIP===" >> $LOG_FILE

./sipp -i $uassserverIP -p $uassserverPort -sf uac_usercalls.xml -nr -m 15 -inf usercalls200.csv -d 55000 -l 15 $SBC1UASIP:5060


sleep 5

./sipp -i $uassserverIP -p $uassserverPort -sf uac_usercalls-emergency.xml -nr -m 8 -inf usercalls13-emergency.csv -d 10000 -l 5 $SBC1UASIP:5060


sleep 5


echo "===SIPp-CALLING-SBC53-$SBC2UASIP===" >> $LOG_FILE

./sipp -i $uassserverIP -p $uassserverPort -sf uac_usercalls.xml -nr -m 15 -inf usercalls200.csv -d 75000 -l 15 $SBC2UASIP:5060


sleep 5

./sipp -i $uassserverIP -p $uassserverPort -sf uac_usercalls-emergency.xml -nr -m 8 -inf usercalls13-emergency.csv -d 10000 -l 5 $SBC2UASIP:5060


sleep 5


echo "===Killing-The-PID-for-SIpp-$PID ===" >> $LOG_FILE
kill -s SIGKILL $PID

# not used anymore
#kill -9 $(ps -ef | grep [s]ipp | awk '{print $2}')

echo "==========================SIPp-CALL-ENDED-$CURRENT_TIMESTAMP===================================" >> $LOG_FILE
}


# main menu

clear

echo "Current DATE: $DATE]" > $LOG_FILE

echo "The Interface name of this system is $iface " >> $LOG_FILE

echo "The IP address of this system is $theIPaddress " >> $LOG_FILE

echo "The Hostname of this system is $HOST_NAME " >> $LOG_FILE


kill_sipp

echo "This script is running"

uac_to_uas_call

kill_sipp

uas_to_uac_call


chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SIPp_CALLS-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;
