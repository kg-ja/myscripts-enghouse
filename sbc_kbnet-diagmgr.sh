#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

LOG_FILE=/tmp/sbc_$HOST_NAME-kbnet-diamgr_output.txt
CMD_kbnet=/opt/bnet/tools/kbnetcmd
CMD_diagmgr=/opt/bnet/tools/rundiagmgr

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
echo "transport type of 6 is tcp  17 is udp   https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> "$LOG_FILE"

commands_kbnet=(
"134"
"26"
"1"
"1"
"0"
)

commands_diagmgr=(
"aetype SCS"
"cd SIP"
"dump algcounts"
"show flowcounts"
"dump total"
"dump longdurationcalls"
"dump mem"
"dump rvstat"
"dump systemstats"
"dump allinterfaces"
"dump allpeers"
"dump ipassoc"
"dump acl"
"exit"
)

echo "================" >> "$LOG_FILE"
echo "KBNET PRINTOUT" >> "$LOG_FILE"
echo "===============" >> "$LOG_FILE"
echo >> "$LOG_FILE"

(
sleep 3
for cmd in "${commands_kbnet[@]}"; do
    echo "$cmd"
    sleep 6
done
) | script -q -a -c "$CMD_kbnet" "$LOG_FILE"

echo >> "$LOG_FILE"
echo "KBNET Run complete: $(date)" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo >> "$LOG_FILE"



echo "================" >> "$LOG_FILE"
echo "DIAGMGR PRINTOUT" >> "$LOG_FILE"
echo "===============" >> "$LOG_FILE"
echo >> "$LOG_FILE"

{
sleep 6

for cmd1 in "${commands_diagmgr[@]}"
do
    echo "$cmd1"
    sleep 5
done

} | $CMD_diagmgr | tee -a "$LOG_FILE"

echo >> "$LOG_FILE"
echo "DIAGMGR Run complete: $(date)" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"
echo >> "$LOG_FILE"

mv "$LOG_FILE" /tmp/sbc_kbnet-diamgr-$HOST_NAME-$SERIAL-$IP_VM-$IP_HW-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0