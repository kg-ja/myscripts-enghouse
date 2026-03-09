#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

LOG_FILE=/tmp/sbc_$HOST_NAME-diagmgr_output.txt
CMD=/opt/bnet/tools/rundiagmgr

touch "$LOG_FILE"
chmod 755 "$LOG_FILE"

echo "=======================================================================================" >> "$LOG_FILE"
echo "Date: $CURRENT_TIMESTAMP" >> "$LOG_FILE"
echo "Host: $HOST_NAME" >> "$LOG_FILE"
echo "Serial: $SERIAL" >> "$LOG_FILE"
echo "VM MGMT IP: $IP_VM" >> "$LOG_FILE"
echo "HP Mgmt IP: $IP_HW" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

commands=(
"aetype SCS"
"cd SIP"
"dump algcounts"
"show flowcounts"
"dump total"
"dump sessions"
"dump mem"
"dump rvstat"
"dump cache"
"dump systemstats"
"dump sesscon"
"exit"
)

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