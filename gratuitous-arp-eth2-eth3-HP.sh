#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
theIPaddressVM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
theIPaddressHW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


LOG_FILE=/tmp/SBC_ETH-TRAFFIC_ARP-$HOST_NAME.log

INTERFACES=("eth2" "eth3")


clear
echo "=======================================================================================" > $LOG_FILE
echo "***$CURRENT_TIMESTAMP - START OF LOG***" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "IP Address of this server is $theIPaddressVM-$theIPaddressHW" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "Serial Number of this server is $theSerial" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "Starting Gratuitous ARP announcements..." | tee -a $LOG_FILE 

# Get all UP interfaces except loopback
# INTERFACES=$(ip -o link show up | awk -F': ' '{print $2}' | grep -v '^lo$')
  INTERFACES=$(ip -o link show up | awk -F': ' '{print $2}' | grep -E '^session(1|2)' | cut -d@ -f1)

for IFACE in $INTERFACES; do

    # Get IPv4 addresses assigned to interface
    IPS=$(ip -4 -o addr show dev "$IFACE" | awk '{print $4}' | cut -d/ -f1)

    if [ -z "$IPS" ]; then
        continue
    fi

    echo "Processing interface: $IFACE" | tee -a $LOG_FILE 

    for IP in $IPS; do
        echo "  Announcing $IP on $IFACE" | tee -a $LOG_FILE 
        arping -U -c 5 -I "$IFACE" "$IP"
    done

done

echo "Gratuitous ARP announcements complete." | tee -a $LOG_FILE 




mv $LOG_FILE /tmp/SBC_ETH-TRAFFIC_ARP-$HOST_NAME-$theSerial-$theIPaddressVM-$theIPaddressHW-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;