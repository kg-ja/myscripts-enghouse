#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)

DIR=/root/sipp-3.7.3

LOG_FILE=/tmp/SIPp_CALL_LOG_INFO-$HOST_NAME.log


echo "==========================SIPp-BASIC-DATA===================================" >> $LOG_FILE


echo "***$CURRENT_TIMESTAMP - START OF LOG***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CPU-INFO***" >> $LOG_FILE
lscpu >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE




echo "==========================SIPp-CALL-STARTED-$CURRENT_TIMESTAMP===================================" >> $LOG_FILE

cd $DIR

# Launch script in background
./sipp -sf uas.xml -i 	192.168.6.228 -p 5060 &

# Get its PID for command above
PID=$!

echo "===The-PID-for-SIpp-is-$PID ===" >> $LOG_FILE


echo "===SIPp-CALLING-SBC IP 192.168.2.100===" >> $LOG_FILE

./sipp -i 192.168.5.5 -p 5060 -sf uacnum.xml -nr -m 1 -d 10000 -l 1 192.168.2.101:5060


sleep 5

echo "===Killing-The-PID-for-SIpp-$PID ===" >> $LOG_FILE
kill -s SIGKILL $PID

# not used anymore
#kill -9 $(ps -ef | grep [s]ipp | awk '{print $2}')

echo "==========================SIPp-CALL-ENDED-$CURRENT_TIMESTAMP===================================" >> $LOG_FILE

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SIPp_CALL_LOG_INFO-$HOST_NAME-$theIPaddress-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;


