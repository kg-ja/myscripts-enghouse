#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

FILE=/opt/bnet/bin/runcommonenv
SEARCH_LINE='export TGW_SIGNAL_SLEEP_TIMER_VALUE=770'
SEARCH_LINE2='export TGW_SIGNAL_SLEEP_TIMER_VALUE=990'

LOG_FILE=/tmp/GCI-SBC_SKEW-CHECK-REMOVAL-INFO-$HOST_NAME.log







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



# Function to find os type
os_find() {

# Extract the OS name from /etc/os-release
if [ -f /etc/os-release ]; then
    os_name=$(grep ^NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
else
    echo "OS information not found."
    exit 1
fi

# Determine OS type
if [[ "$os_name" == *"Rocky Linux"* ]]; then
    OS_TYPE="rocky"
    echo "This is Rocky OS." | tee -a $LOG_FILE
elif [[ "$os_name" == *"CentOS"* ]]; then
    OS_TYPE="centos"
    echo "This is CentOS." | tee -a $LOG_FILE
else
    OS_TYPE="unknown"
    echo "OS is not rocky linux for CentOS." | tee -a $LOG_FILE
	exit 1
fi
}

# Function to display skew value
skew_value() {
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE
echo "*SLEEP_TIMER_VALUE CHECK*" | tee -a $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE| tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
}








# Function to remove skew value
skew_removal() {

echo "Backing up runcommonenv" | tee -a $LOG_FILE
cp /opt/bnet/bin/runcommonenv /archive/home/sysadmin/runcommonenv-bak
chmod a=r /archive/home/sysadmin/runcommonenv-bak
echo "=======================================================================================" >> $LOG_FILE


echo "removing sleep timer value from file runcommonenv" | tee -a $LOG_FILE

cd /opt/bnet/bin/

if [[ "$OS_TYPE" == "centos" ]]; then
   sed -i '/^export TGW_SIGNAL_SLEEP_TIMER_VALUE=770$/d' runcommonenv
    echo "Skew value is now removed" | tee -a $LOG_FILE
    
elif [[ "$OS_TYPE" == "rocky" ]]; then
     sed -i '/^export TGW_SIGNAL_SLEEP_TIMER_VALUE=990$/d' runcommonenv
	  echo "Skew value is now removed" | tee -a $LOG_FILE
fi



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


# Function to check skew value then call skew removal if needed
skew_check() {
if [[ "$OS_TYPE" == "centos" ]] && grep -Fxq "$SEARCH_LINE" "$FILE"; then
    echo "Skew parameter value is set, action will now be taken to remove(CentOS)" | tee -a $LOG_FILE
	skew_removal
	skew_value

elif [[ "$OS_TYPE" == "rocky" ]] && grep -Fxq "$SEARCH_LINE2" "$FILE"; then
    echo "Skew parameter value is set, action will now be taken to remove(Rocky Linux)" | tee -a $LOG_FILE
	skew_removal
	skew_value
	
else
    echo "Skew parameter is not present so no action taken" | tee -a $LOG_FILE    
	 
	 skew_value
fi
}




# Main loop, will check if skew is set and remove
get_server_info    
os_find
skew_check






chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/GCI-SBC_SKEW-CHECK-REMOVAL-INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0
