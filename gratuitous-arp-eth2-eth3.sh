#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
theIPaddressVM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


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
echo "IP Address of this server is $theIPaddressVM" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "Serial Number of this server is $theSerial" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "Starting gratuitous ARP announcements..." | tee -a $LOG_FILE 

for INTERFACE in "${INTERFACES[@]}"; do

    # Get all IPv4 addresses for this interface
    IPS=$(ip -4 -o addr show dev "$INTERFACE" | awk '{print $4}' | cut -d/ -f1)

    if [ -z "$IPS" ]; then
        echo "No IPv4 addresses found on $INTERFACE" | tee -a $LOG_FILE 
        continue
    fi

    echo "Processing interface: $INTERFACE" | tee -a $LOG_FILE 

    for IP in $IPS; do
        echo "  Announcing IP: $IP on $INTERFACE" | tee -a $LOG_FILE 
        arping -U -c 5 -I "$INTERFACE" "$IP"
    done

done

echo "Gratuitous ARP announcements complete." | tee -a $LOG_FILE 

mv $LOG_FILE /tmp/SBC_ETH-TRAFFIC_ARP-$HOST_NAME-$theSerial-$theIPaddressVM-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;