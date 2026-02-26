#!/bin/bash


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
theIPaddressVM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
theIPaddressHW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
backup_dir=/config/mibs/
config_dir=/config/mibs/current


Peer_hostname=uscskgsbc103sec
HA_Link_Peer_IP=10.122.21.58


LOG_FILE=/tmp/-CLONING-FIX-$HOST_NAME.log

clear
echo "=======================================================================================" > $LOG_FILE
echo "***$CURRENT_TIMESTAMP-$HOST_NAME-$theIPaddressVM-$theIPaddressHW-START OF LOG***" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


cd $config_dir
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
git status >> $LOG_FILE 
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
git log >> $LOG_FILE 
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
git branch -v >> $LOG_FILE 
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
ps -ef | grep git >> $LOG_FILE 
echo "=======================================================================================" >> $LOG_FILE

# Changing to backup directory
echo "Changing to mib directory..." | tee -a $LOG_FILE

cd $backup_dir

echo | tee -a "$LOG_FILE"
echo "stopping bnet services..." | tee -a $LOG_FILE 

bnetstop

echo | tee -a "$LOG_FILE"
echo "renaming config folder..." | tee -a $LOG_FILE 

mv current current_before_resync

echo | tee -a "$LOG_FILE"

echo "performing cloning and other actions" | tee -a $LOG_FILE

git clone git://$HA_Link_Peer_IP/config/mibs/current

cd $config_dir

git remote add $Peer_hostname git://$HA_Link_Peer_IP/config/mibs/current

echo | tee -a "$LOG_FILE"

echo "restarting bnet services" | tee -a $LOG_FILE

bnetstart

sleep 15

echo | tee -a "$LOG_FILE"

echo "bnet services restarted" | tee -a $LOG_FILE

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/CLONING-FIX-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;