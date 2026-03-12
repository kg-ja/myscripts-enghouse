#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
IP_VM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


LOG_FILE=/tmp/SBC_BNETSCS_RAM_USAGE-$HOST_NAME-$theSerial-$IP_VM-$IP_HW-$(date +"%Y_%m_%d_%I_%M_%p").log


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

bnetscsscript_check()
{

COUNT=$(pgrep -fc "sbc_bnetscs_ram_usage.sh")

if [ "$COUNT" -gt 1 ]; then
    echo "ERROR: sbc_bnetscs_ram_usage.sh is already running ($COUNT instances detected)."
    exit 1
fi
}

bnetscs_ramusage()
{
echo "BNETSCS RAM USAGE:" >> "$LOG_FILE"

PID=$(pgrep -f "^/usr/lib64/ld-linux.* /opt/bnet/bin/bnetscs")

if [ -z "$PID" ]; then
  echo "bnetscs not running" >> "$LOG_FILE"
  exit 1
fi

while true; do
  if ps -p "$PID" > /dev/null 2>&1; then
    printf "%s " "$(date '+%F %T')" >> "$LOG_FILE"
    ps -p "$PID" -o rss= >> "$LOG_FILE"
  else
    printf "%s PID %s not running\n" "$(date '+%F %T')" "$PID" >> "$LOG_FILE"
	echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
    echo "NEW BNETSCS PROCESS" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    ps -ef | grep -E '/opt/bnet/bin/runbnetscs|/opt/bnet/bin/bnetscs' | grep -v grep  >> "$LOG_FILE"
    echo >> "$LOG_FILE"
    echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
    exit 1
  fi
  sleep 60
done

}



# MAIN
bnetscsscript_check
hardware_platform
bnetscs_ramusage

echo | tee -a "$LOG_FILE"
 
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"
chmod 755 "$LOG_FILE"

echo "This script has completed, please check /tmp folder for SBC_LOG_INFO-* log to send to support" 

exit 0;