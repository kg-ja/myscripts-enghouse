#!/bin/bash

clear

# Default values
snmp_etc_config=/etc/snmp/snmpd.conf
snmp_varlib_config=/var/lib/net-snmp/snmpd.conf

SEARCH_LINE='view    systemview    included    .1'

CURRENT_TIMESTAMP=`date`

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

LOG_FILE=/tmp/SNMP-FIX-$HOST_NAME.log



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


}



get_snmpd_info() {


echo "CURRENT ENTRY" | tee -a $LOG_FILE

echo "---------------------------------------------" | tee -a $LOG_FILE

cat /etc/snmp/snmpd.conf | grep .1 | grep view | grep -v all | grep -v roview |grep -v rwview | tee -a $LOG_FILE


echo "---------------------------------------------" | tee -a $LOG_FILE

}




snmpd_change() {

echo "Snmpd adjustment will now be made" | tee -a $LOG_FILE
sleep 1
echo "Stopping snmpd service" | tee -a $LOG_FILE

service snmpd stop

cp $snmp_etc_config /etc/snmp/snmpd.conf.etcbackup-$(date +"%Y_%m_%d_%I_%M_%p")


echo "Snmpd change now being made" | tee -a $LOG_FILE
#comment out lines
sed -i 's|^\(view[[:space:]]*systemview[[:space:]]*included[[:space:]]*.1.3.*\)|#\1|' $snmp_etc_config 

# add working line
sed -i '/#view[[:space:]]*systemview[[:space:]]*included[[:space:]]*.1.3.6.1.2.1.25.1.1/a view    systemview    included    .1' $snmp_etc_config 

sleep 1

echo "Starting snmpd service" | tee -a $LOG_FILE
service snmpd start


echo "---------------------------------------------" >> $LOG_FILE
cd /etc/snmp/

echo "***/etc/snmp/ Files***" >> $LOG_FILE

ls -ltr >> $LOG_FILE

echo "---------------------------------------------"  >> $LOG_FILE


}




# Main loop, will check if snmpd adjustment already made

if grep -Fxq "$SEARCH_LINE" "$snmp_etc_config"; then
    
   get_server_info 
   get_snmpd_info   

   echo "snmpd adjustment already set no action taken" | tee -a $LOG_FILE

else  
    
   get_server_info
   get_snmpd_info
   echo "snmpd adjustment not done, action will now be taken to do it" | tee -a $LOG_FILE
   snmpd_change
   get_snmpd_info

   echo "snmpd adjustment done" | tee -a $LOG_FILE
fi











chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SNMP-FIX-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;
