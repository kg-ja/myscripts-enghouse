#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
SUMMARY=$(/opt/bnet/scripts/swMgr Summary | awk -F'|' '{print $1 "|" $2 "|" $3 "|"}')




DIR=/archive/home/sysadmin/
FILE=/archive/home/sysadmin/bnetscs
FILE2=/opt/bnet/bin/bnetscs.original
FILE3=/opt/bnet/bin/bnetscs
DIR2=/opt/bnet/bin/




LOG_FILE=/tmp/SBC_BNETSCS-REVERTCHANGE-$HOST_NAME.log







# Function to get server details
get_server_info() {

# clear the screen to present the information
  clear

echo | tee -a "$LOG_FILE"
echo "Script running, please wait" 
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "INTERFACE NAME OF THIS SYSTEM IS: $iface" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "IP ADDRESS OF THIS SYSTEM IS: $theIPaddress" >> $LOG_FILE
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

echo "***Full summary of available and used disk space usage of the file system***" >> $LOG_FILE
df -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***STORAGE-INFO***" >> $LOG_FILE
du -sh /archive/software/ >> $LOG_FILE
du -sh /cores >> $LOG_FILE
du -sh /var/crash/ >> $LOG_FILE
du -sh /eventdata/ >> $LOG_FILE
du -sh /archive/backup/config >> $LOG_FILE
du -sh /archive/SIP_capture >> $LOG_FILE
du -sh /archive/Trace_captures >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

du -h / --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --max-depth=1 | sort -rh | head -20 >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
top -b -o %MEM | head -n 16 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CPU-PRINTOUT***" >> $LOG_FILE
top -b -o %CPU | head -n 16 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /proc/kbnet/cpu_usage >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***SYSTEM-UPTIME-INFO***" >> $LOG_FILE
uptime >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***Time Of Last System Boot***" >> $LOG_FILE
who -b >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***System Reboots***" >> $LOG_FILE
last reboot >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo | tee -a "$LOG_FILE"

}


# Function to find os type
bnetscs_file() {

clear

echo | tee -a "$LOG_FILE"

# Look for bnetscs file
if [ -f $FILE2 ]; then
    echo "bnetscs.original file found "
	echo | tee -a "$LOG_FILE"
else
    echo "bnetscs file information not found in directory $DIR2 "
	 echo "No changes will be made"
	echo | tee -a "$LOG_FILE"
    exit 1
fi


if [ -f $FILE3 ]; then
    echo "bnetscs file exists in /opt/bnet/bin script will proceed "
	echo | tee -a "$LOG_FILE"
	
else
    echo "bnetscsnot found, script will not proceed"	 
	echo | tee -a "$LOG_FILE"
	exit 1
    
fi

}

# Function to find os type
os_find() {

echo | tee -a "$LOG_FILE"
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
	echo | tee -a "$LOG_FILE"
elif [[ "$os_name" == *"CentOS"* ]]; then
    OS_TYPE="centos"
    echo "This is CentOS." | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
else
    OS_TYPE="unknown"
    echo "OS is not rocky linux or CentOS." | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
	exit 1
fi
}


# Function to display bnetscs file information
processes_info() {
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE
cd /opt/bnet/bin
ls -ltr >> $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
ls -ltrh | grep bnetscs  | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
}



# Function to add skew value
bnetscs_revert() {
echo | tee -a "$LOG_FILE"

echo "stopping all SBC processes" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

bnetstop


cd /opt/bnet/bin

echo "renaming modified bnetscs file" | tee -a $LOG_FILE

mv bnetscs bnetscs.modified

echo | tee -a "$LOG_FILE"

echo "renaming bnetscs.original file" | tee -a $LOG_FILE

mv bnetscs.original bnetscs



echo | tee -a "$LOG_FILE"

echo "changing ownership and permission" | tee -a $LOG_FILE

chown root:root bnetscs

chmod u=rwx,g=rx,o=rx bnetscs


echo "stopping and starting all SBC processes , please wait" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

bnetstart

sleep 35

echo "all SBC processes started " | tee -a $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
}




# Main loop, will check if bnetscs file there and execute script
      
   bnetscs_file
   get_server_info
   os_find
   processes_info
   bnetscs_revert
   processes_info

 
chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SBC_BNETSCS-REVERTCHANGE-$HOST_NAME-$theIPaddress-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

echo "This script has completed" 

exit 0;
