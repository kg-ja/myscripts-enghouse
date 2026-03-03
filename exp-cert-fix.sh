#!/bin/bash


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
config_dir=/opt/glassfish/glassfish/domains/domain1/config/


YOUR_ALIAS=newbnet4000
server_YOUR_MANAGEMENT_IP=10.61.13.28


LOG_FILE=/tmp/$YOUR_ALIAS-CERT-FIX-$HOST_NAME.log



# Changing to config directory
echo "Changing to config directory..." | tee -a $LOG_FILE

cd $config_dir

echo | tee -a "$LOG_FILE"
echo "config changes being made and generating cert..." | tee -a $LOG_FILE 

/usr/bin/keytool -genkey -alias $YOUR_ALIAS -keyalg RSA -keypass changeit -storepass changeit -keystore keystore.jks -validity 3650 -dname "CN=$server_YOUR_MANAGEMENT_IP, OU=SBC, O=Dialogic Inc.,L=Milpitas,S=California,C=US" -noprompt

/usr/bin/keytool -export -alias $YOUR_ALIAS -storepass changeit -file $server_YOUR_MANAGEMENT_IP.cer -keystore keystore.jks

/usr/bin/keytool -import -v -trustcacerts -alias $YOUR_ALIAS -file $server_YOUR_MANAGEMENT_IP.cer -keystore cacerts.jks -keypass changeit -storepass changeit -noprompt

sleep 4

echo "config changes completed " | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

echo "Go to / Application / Digital Certificates/BIND and select Use This Certificate $YOUR_ALIAS " | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/$YOUR_ALIAS-CERT-FIX-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;