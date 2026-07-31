#!/bin/bash


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
sysctl_file=/etc/sysctl.conf

LOG_FILE=/tmp/SYS_FILE-BACKUP-$HOST_NAME.log


# backing up sysctl.conf file
echo "backing up $sysctl_file " | tee -a $LOG_FILE
cp $sysctl_file /tmp/$HOST_NAME-sysctl.conf-bck
sleep 1
echo "backing up of $sysctl_file completed " | tee -a $LOG_FILE

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SYS_FILE-BACKUP-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;