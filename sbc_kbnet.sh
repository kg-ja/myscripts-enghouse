#!/bin/bash

LOG_FILE="/tmp/kbnet_output.txt"
CMD="/opt/bnet/tools/kbnetcmd"

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)

touch "$LOG_FILE"
chmod 755 "$LOG_FILE"

echo "=======================================================================================" >> "$LOG_FILE"
echo "*** $CURRENT_TIMESTAMP ***" >> "$LOG_FILE"
echo "Host: $HOST_NAME" >> "$LOG_FILE"
echo "Serial: $SERIAL" >> "$LOG_FILE"
echo "VM IP: $IP_VM" >> "$LOG_FILE"
echo "Mgmt IP: $IP_HW" >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

commands=(
"134"
"26"
"1"
"1"
"0"
)

(
sleep 3
for cmd in "${commands[@]}"; do
    echo "$cmd"
    sleep 6
done
) | script -q -a -c "$CMD" "$LOG_FILE"

echo >> "$LOG_FILE"
echo "Run complete: $(date)" >> "$LOG_FILE"
echo >> "$LOG_FILE"

exit 0