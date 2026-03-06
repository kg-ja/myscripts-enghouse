#!/bin/bash


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
config_dir=/archive/backup/config/


sbc_pri_hostname=guydl380sbchs01
sbc_mgmt_ip=10.61.13.25


LOG_FILE=/tmp/$sbc_pri_hostname-CERT-FIX-$HOST_NAME.log



# Changing to config directory
echo "Changing to config directory..." | tee -a $LOG_FILE

cd $config_dir

echo | tee -a "$LOG_FILE"
echo "git pull of master primary..." | tee -a $LOG_FILE 

git pull $sbc_pri_hostname master --allow-unrelated-histories

echo "git pull of master primary completed " | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

echo "performing other actions" | tee -a $LOG_FILE

/bin/cp -f cacerts.jks /opt/glassfish/glassfish/domains/domain1/config

/bin/cp -f keystore.jks /opt/glassfish/glassfish/domains/domain1/config

/bin/cp -f server_$sbc_mgmt_ip.cer /opt/glassfish/glassfish/domains/domain1/config

echo | tee -a "$LOG_FILE"

echo "restarting glassfish" | tee -a $LOG_FILE

systemctl restart glassfish

sleep 4

echo | tee -a "$LOG_FILE"

echo "glassfish restarted" | tee -a $LOG_FILE

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/$sbc_pri_hostname-CERT-FIX-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;