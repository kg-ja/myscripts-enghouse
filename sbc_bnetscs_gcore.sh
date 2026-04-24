#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
IP_VM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)

Currentdirectory=$(pwd)

LOG_FILE=/tmp/SBC_BNETSCS_GCORE-$HOST_NAME-$theSerial-$IP_VM-$IP_HW-$(date +"%Y_%m_%d_%I_%M_%p").log


hardware_platform()
{
echo "=======================================================================================" > "$LOG_FILE"
echo "***$CURRENT_TIMESTAMP - START OF LOG***" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo "1.HARDWARE BASIC INFO" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo "Date: $CURRENT_TIMESTAMP" >> "$LOG_FILE"
echo "Hostname: $HOST_NAME" >> "$LOG_FILE"
echo "VM MGMT IP: $IP_VM" >> "$LOG_FILE"
echo "HP Mgmt IP: $IP_HW" >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
echo "HW/VM -SBC-License-Platform-Details" >> "$LOG_FILE"
dmidecode -t system | grep Manufacturer >> "$LOG_FILE"
dmidecode -t system | grep Product >> "$LOG_FILE"
dmidecode -t system | grep Serial >> "$LOG_FILE"
dmidecode -t system | grep UUID >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
cat /opt/bnet/release_info >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
/opt/bnet/scripts/getVMVSystemInfo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
/opt/bnet/scripts/swMgr Summary >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"

/opt/bnet/bin/bnetscs -ver >> "$LOG_FILE"

echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"

echo >> "$LOG_FILE"

echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
echo "BNETSCS PROCESS" >> "$LOG_FILE"
echo >> "$LOG_FILE"
ps -ef | grep -E '/opt/bnet/bin/runbnetscs|/opt/bnet/bin/bnetscs' | grep -v grep  >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
}

# CHECK IF ANOTHER INSTANCE OF SCRIPT RUNNING


bnetscs_gcore()
{
echo "BNETSCS PROCESS:" >> "$LOG_FILE"

PID=$(pgrep -f "^/usr/lib64/ld-linux.* /opt/bnet/bin/bnetscs")

if [ -z "$PID" ]; then
  echo "bnetscs not running" | tee -a $LOG_FILE 
  exit 1
fi
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
ps -ef | grep bnetscs
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
echo | tee -a $LOG_FILE

echo "BNETSCS PROCESS ID is $PID :" | tee -a $LOG_FILE  

echo | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"


gcore $PID


chmod 755 core*


}



# MAIN
hardware_platform
bnetscs_gcore

echo | tee -a "$LOG_FILE"
 
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
chmod 755 "$LOG_FILE"

clear
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
echo "Current Directory is $Currentdirectory " >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
ls -ltrh >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"

echo "This script has completed, please check $Currentdirectory folder for file starting with core.* and to send to support" 

exit 0;