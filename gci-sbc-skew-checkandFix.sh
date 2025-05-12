#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

FILE=/opt/bnet/bin/runcommonenv
SEARCH_LINE='export TGW_SIGNAL_SLEEP_TIMER_VALUE=770'

LOG_FILE=/tmp/GCI-SBC_SKEW-CHECK-FIX_INFO-$HOST_NAME.log







# Function to get server details
get_server_info() {

# clear the screen to present the information
  clear

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***-SBC-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "*** HW/VM -SBC-License-Platform-Details***" >> $LOG_FILE

dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE
echo "Printout /opt/bnet/bin/runcommonenv" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "*SLEEP_TIMER_VALUE CHECK*" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep SLEEP /archive/logger/*/bnett* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

}




# Function to add skew value
skew_change() {

echo "Backing up runcommonenv" | tee -a $LOG_FILE
cp /opt/bnet/bin/runcommonenv /archive/home/sysadmin/runcommonenv-backup
chmod a=r /archive/home/sysadmin/runcommonenv-backup
echo "=======================================================================================" >> $LOG_FILE


echo "Adding sleep timer value to file runcommonenv" | tee -a $LOG_FILE

cd /opt/bnet/bin/

sed -i '/^ulimit -n 256000 /a export TGW_SIGNAL_SLEEP_TIMER_VALUE=770' runcommonenv


echo "=======================================================================================" >> $LOG_FILE
echo "Printout /opt/bnet/bin/runcommonenv" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*BNETSCS-SERVICE*" >> $LOG_FILE
systemctl status bnetscs  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*BNETTGW-SERVICE*" >> $LOG_FILE
systemctl status bnettgw  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "stopping processes bnetscs and bnettgw, please wait" | tee -a $LOG_FILE
systemctl stop bnetscs
systemctl stop bnettgw

sleep 30

clear
echo "starting processes bnetscs and bnettgw, please wait" | tee -a $LOG_FILE
systemctl start bnetscs
systemctl start bnettgw

sleep 35
clear
echo "processes bnetscs and bnettgw started" | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "**BNETSCS-SERVICE**" >> $LOG_FILE
systemctl status bnetscs  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "**BNETTGW-SERVICE**" >> $LOG_FILE
systemctl status bnettgw  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE



echo "=======================================================================================" >> $LOG_FILE
echo "*SLEEP_TIMER_VALUE CHECK*" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep SLEEP /archive/logger/*/bnett* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

}




# Main loop, will check if skew is set and correct if not

if grep -Fxq "$SEARCH_LINE" "$FILE"; then
    
   get_server_info    

   echo "Skew parameter already set no action taken" | tee -a $LOG_FILE

else  
    
   get_server_info
   echo "Skew parameter value not set, action will now be taken to add it" | tee -a $LOG_FILE
   skew_change

   echo "Skew value is now set" | tee -a $LOG_FILE
fi






chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/GCI-SBC_SKEW-CHECK-FIX_INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0
