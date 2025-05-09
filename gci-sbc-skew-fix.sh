#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

LOG_FILE=/tmp/GCI-SBC_SKEW-FIX_INFO-$HOST_NAME.log


echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***Printout /opt/bnet/bin/runcommonenv ***" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***backing up runcommonenv  ***" >> $LOG_FILE
cp /opt/bnet/bin/runcommonenv /archive/home/sysadmin/runcommonenv-backup
chmod a=r /archive/home/sysadmin/runcommonenv-backup
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***SLEEP_TIMER_VALUE CHECK ***" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep SLEEP /archive/logger/*/bnett* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***adding sleep timer value to file runcommonenv  ***" >> $LOG_FILE

cd /opt/bnet/bin/

sed -i '/^ulimit -n 256000 /a export TGW_SIGNAL_SLEEP_TIMER_VALUE=770' runcommonenv


echo "=======================================================================================" >> $LOG_FILE
echo "***Printout /opt/bnet/bin/runcommonenv ***" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETSCS-SERVICE***" >> $LOG_FILE
systemctl status bnetscs  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETTGW-SERVICE***" >> $LOG_FILE
systemctl status bnettgw  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***stopping processes bnetscs bnettgw   ***" >> $LOG_FILE
systemctl stop bnetscs
systemctl stop bnettgw

sleep 30

echo "***starting processes bnetscs bnettgw   ***" >> $LOG_FILE
systemctl start bnetscs
systemctl start bnettgw

sleep 5

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETSCS-SERVICE***" >> $LOG_FILE
systemctl status bnetscs  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETTGW-SERVICE***" >> $LOG_FILE
systemctl status bnettgw  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE



echo "=======================================================================================" >> $LOG_FILE
echo "***SLEEP_TIMER_VALUE CHECK ***" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep SLEEP /archive/logger/*/bnett* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/GCI-SBC_SKEW-FIX_INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;



