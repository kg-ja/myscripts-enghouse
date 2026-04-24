#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

LOG_FILE=/tmp/sbc_$HOST_NAME-$SERIAL-$IP_VM-$IP_HW-diagmgr_config_output.txt
CMD=/opt/bnet/tools/rundiagmgr

touch "$LOG_FILE"
chmod 755 "$LOG_FILE"

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
echo >> "$LOG_FILE"

commands=(
"aetype SCS"
"cd SIP"
"dump allinterfaces"
"dump allpeers"
"dump ipassoc "
"dump mem"
"dump rvstat"
"exit"
)

echo "================" >> "$LOG_FILE"
echo "DIAGMGR PRINTOUT" >> "$LOG_FILE"
echo "===============" >> "$LOG_FILE"
echo >> "$LOG_FILE"

{
sleep 6

for cmd in "${commands[@]}"
do
    echo "$cmd"
    sleep 5
done

} | $CMD | tee -a "$LOG_FILE"

echo >> "$LOG_FILE"
echo "Run complete: $(date)" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo >> "$LOG_FILE"

exit 0