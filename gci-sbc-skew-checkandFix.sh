#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
IP_VM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)

FILE=/opt/bnet/bin/runcommonenv
SEARCH_LINE='export TGW_SIGNAL_SLEEP_TIMER_VALUE=770'
SEARCH_LINE2='export TGW_SIGNAL_SLEEP_TIMER_VALUE=990'

LOG_FILE=/tmp/GCI-SBC_SKEW-CHECK-FIX_INFO-$HOST_NAME-$theSerial-$IP_HW-$(date +"%Y_%m_%d_%I_%M_%p").txt







# Function to get server details
get_server_info() {

# clear the screen to present the information
  clear

echo "1.HARDWARE BASIC INFO" >> $LOG_FILE
echo >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo "Date: $CURRENT_TIMESTAMP" >> "$LOG_FILE"
echo "Hostname: $HOST_NAME" >> "$LOG_FILE"
echo "VM MGMT IP: $IP_VM" >> "$LOG_FILE"
echo "HP Mgmt IP: $IP_HW" >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "HW/VM -SBC-License-Platform-Details" >> $LOG_FILE
dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /opt/bnet/release_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/getVMVSystemInfo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

/opt/bnet/bin/bnetscs -ver >> $LOG_FILE

echo >> "$LOG_FILE"
echo >> "$LOG_FILE"
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



# Function to add skew value
skew_change() {
echo | tee -a "$LOG_FILE"

echo "Backing up runcommonenv" | tee -a $LOG_FILE
cp /opt/bnet/bin/runcommonenv /archive/home/sysadmin/runcommonenv-backup
chmod a=r /archive/home/sysadmin/runcommonenv-backup
echo "=======================================================================================" >> $LOG_FILE


echo "Adding sleep timer value to file runcommonenv" | tee -a $LOG_FILE

cd /opt/bnet/bin/

if [[ "$OS_TYPE" == "centos" ]]; then
   sed -i '/^ulimit -n 256000 /a export TGW_SIGNAL_SLEEP_TIMER_VALUE=770' runcommonenv
    echo "Skew value is now set" | tee -a $LOG_FILE
    
elif [[ "$OS_TYPE" == "rocky" ]]; then
     sed -i '/^ulimit -n 256000 /a export TGW_SIGNAL_SLEEP_TIMER_VALUE=990' runcommonenv
	  echo "Skew value is now set" | tee -a $LOG_FILE
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



# Function to check skew value then call skew change to add if needed
skew_check() {
if [[ "$OS_TYPE" == "centos" ]] && grep -Fxq "$SEARCH_LINE" "$FILE"; then
    echo "Skew parameter already set no action taken(CentOS)" | tee -a $LOG_FILE
	skew_value

elif [[ "$OS_TYPE" == "rocky" ]] && grep -Fxq "$SEARCH_LINE2" "$FILE"; then
    echo "Skew parameter already set no action taken(Rocky Linux)" | tee -a $LOG_FILE
	skew_value
	
else
    echo "Skew parameter value not set, action will now be taken to add it" | tee -a $LOG_FILE
     skew_change
	 echo "Skew value is now set" | tee -a $LOG_FILE
	 skew_value
fi
}




# Main loop, will check if skew is set and add if not


   get_server_info    
   os_find
   skew_check

 
chmod 755 $LOG_FILE


echo "This script has completed........" 
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
echo "Log File  : $LOG_FILE" | tee -a $LOG_FILE
echo "==============================================" | tee -a $LOG_FILE

exit 0;
