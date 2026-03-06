#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

INTERFACE_CSCF_SIG="session1.3088"
INTERFACE_MGCF_SIG="session2.3087"

INTERFACE_CSCF_MEDIA="session1.3086"
INTERFACE_MGCF_MEDIA="session2.3085"


SIG_CSCF_EOTN_IP_LIST=(
  10.5.196.192
  10.5.196.194
  10.5.196.193
  10.5.196.197  
)


SIG_MGCF_EOTN_IP_LIST=(
  10.5.196.4    
)


MEDIA_CSCF_EOTN_IP_LIST=(
  10.5.198.185
  10.5.198.186
  10.5.198.187 
  10.5.198.168
  10.5.198.169
  10.5.198.167
)


MEDIA_MGCF_EOTN_IP_LIST=(
  172.21.72.130
  172.21.72.131
  172.21.72.194
  172.21.73.130
  172.21.73.131
  172.21.73.194
)





LOG_FILE=/tmp/SBC_SADC_EOTN_PING_CHECK_INFO-$HOST_NAME.log


clear
echo "=======================================================================================" >> $LOG_FILE
echo "***$CURRENT_TIMESTAMP - START OF LOG***" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo | tee -a "$LOG_FILE"

echo "***-SBC-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

eecho "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "*** HW/VM -SBC-License-Platform-Details***" >> $LOG_FILE

dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "***NETWORK-STATS***" >> $LOG_FILE
ip address >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
ifconfig -a >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ROTUING-INFO*" >> $LOG_FILE
ip route >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
route >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ARP-TABLE*" >> $LOG_FILE
arp -a >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"


cat << EOF >> $LOG_FILE
Signaling 

Name: rtc_CSCF_sig_sp1
Ethernet Link: SessionIf 1
VLAN ID: 3088
IP Address Type:IPv4
IP Address: 10.5.248.212
Subnet Mask:29
Gateway: 10.5.248.209
----------------------------------------------------------------
Name: rtc_MGCF_sig_sp1
Ethernet Link: SessionIf 2
VLAN ID: 3087
IP Address Type: IPv4
IP Address: 10.5.248.220
Subnet Mask: 29
Gateway: 10.5.248.217

================================================================
Media
 
Name: rtc_BGF_media_sp1
Ethernet Link: SessionIf 1
VLAN ID: 3086
IP Address Type: IPv4
IP Address: 10.5.248.228
Subnet Mask: 29
Gateway: 10.5.248.225

Name: rtc_MGW_media_sp1
Ethernet Link: SessionIf 2
VLAN ID: 3085
IP Address Type: IPv4
IP Address: 10.5.248.236
Subnet Mask: 29
Gateway: 10.5.248.233
=====================================================================
EOF

echo | tee -a "$LOG_FILE"
echo "Script running, please wait" 
echo | tee -a "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo | tee -a "$LOG_FILE"

echo "Checking signaling connectivity, please wait" 

echo | tee -a "$LOG_FILE"

sleep 1

echo "Checking CSCF signaling connectivity, please wait" 

for TARGET_IP in "${SIG_CSCF_EOTN_IP_LIST[@]}"; do
    echo " Checking connectivity to CSCF SIGNALING $TARGET_IP" | tee -a "$LOG_FILE"
    ping -I "$INTERFACE_CSCF_SIG" -c 3 -W 2 "$TARGET_IP" >> "$LOG_FILE"

    if [ $? -eq 0 ]; then
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP successful" | tee -a "$LOG_FILE"
    else
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP failed, traceroute and tracepath will be done...." | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        traceroute -i "$INTERFACE_CSCF_SIG" "$TARGET_IP" | tee -a "$LOG_FILE"
        echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
        tracepath -4 -b "$TARGET_IP" | tee -a "$LOG_FILE"
    fi

    echo "=======================================================================================" | tee -a "$LOG_FILE"
done

echo | tee -a "$LOG_FILE"

sleep 1

echo "Checking MGCF signaling connectivity, please wait" 


for TARGET_IP in "${SIG_MGCF_EOTN_IP_LIST[@]}"; do
    echo " Checking connectivity to MGCF SIGNALING $TARGET_IP" | tee -a "$LOG_FILE"
    ping -I "$INTERFACE_MGCF_SIG" -c 3 -W 2 "$TARGET_IP" >> "$LOG_FILE"

    if [ $? -eq 0 ]; then
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP successful" | tee -a "$LOG_FILE"
    else
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP failed, traceroute and tracepath will be done...." | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        traceroute -i "$IINTERFACE_MGCF_SIG" "$TARGET_IP" | tee -a "$LOG_FILE"
        echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
        tracepath -4 -b "$TARGET_IP" | tee -a "$LOG_FILE"
    fi

    echo "=======================================================================================" | tee -a "$LOG_FILE"
done

echo | tee -a "$LOG_FILE"

sleep 2

clear

echo | tee -a "$LOG_FILE"

echo "Checking MGCF media side connectivity, please wait" 

echo | tee -a "$LOG_FILE"



for TARGET_IP in "${MEDIA_MGCF_EOTN_IP_LIST[@]}"; do
    echo " Checking connectivity to MGCF EOTN MEDIA $TARGET_IP" | tee -a "$LOG_FILE"
    ping -I "$INTERFACE_MGCF_MEDIA" -c 3 -W 2 "$TARGET_IP" >> "$LOG_FILE"

    if [ $? -eq 0 ]; then
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP successful" | tee -a "$LOG_FILE"
    else
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP failed, traceroute and tracepath will be done...." | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        traceroute -i "$INTERFACE_MGCF_MEDIA" "$TARGET_IP" | tee -a "$LOG_FILE"
        echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
        tracepath -4 -b "$TARGET_IP" | tee -a "$LOG_FILE"
    fi

    echo "=======================================================================================" | tee -a "$LOG_FILE"
done


sleep 2

clear

echo | tee -a "$LOG_FILE"

echo "Checking CSFC media side  connectivity, please wait" 

echo | tee -a "$LOG_FILE"



for TARGET_IP in "${MEDIA_CSCF_EOTN_IP_LIST[@]}"; do
    echo " Checking connectivity to CSCF_EOTN MEDIA $TARGET_IP" | tee -a "$LOG_FILE"
    ping -I "$INTERFACE_CSCF_MEDIA" -c 3 -W 2 "$TARGET_IP" >> "$LOG_FILE"

    if [ $? -eq 0 ]; then
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP successful" | tee -a "$LOG_FILE"
    else
	    echo | tee -a "$LOG_FILE"
        echo "Connectivity to $TARGET_IP failed, traceroute and tracepath will be done...." | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        traceroute -i "$INTERFACE_CSCF_MEDIA" "$TARGET_IP" | tee -a "$LOG_FILE"
        echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
        tracepath -4 -b "$TARGET_IP" | tee -a "$LOG_FILE"
    fi

    echo "=======================================================================================" | tee -a "$LOG_FILE"
done




echo | tee -a "$LOG_FILE"
 

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SBC_SADC_EOTN_PING_CHECK_INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

echo "This script has completed, please check /tmp folder for SBC_PING_CHECK_INFO-$HOST_NAME-* log to send to support" 

exit 0;






