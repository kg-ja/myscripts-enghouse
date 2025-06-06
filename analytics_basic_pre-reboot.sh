#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

LOG_FILE=/tmp/ANALYTICS_PRE-REBOOT-$HOST_NAME.log

clear

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***CPU-INFO***" >> $LOG_FILE
lscpu >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -k >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "IP ADDRESS OF THIS SYSTEM IS: $theIPaddress" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "***SERVICES_STATUS***" | tee -a $LOG_FILE
echo "-----------------------------------" | tee -a $LOG_FILE

echo "***ELASTICSEARCH-SERVICE***" | tee -a $LOG_FILE
systemctl status elasticsearch.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE

echo "***DATAREADER-SERVICE***" | tee -a $LOG_FILE
systemctl status datareader.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILEE

echo "***KIBANA-SERVICE***" | tee -a $LOG_FILE
systemctl status kibana.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE


echo "***RABBITMQ-SERVICE***" | tee -a $LOG_FILE
systemctl status rabbitmq-server | grep "Active\b" >> $LOG_FILE 
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE


echo "***RABBITMQ-QUEUES***" | tee -a $LOG_FILE
rabbitmqctl list_queues | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE

sleep 3

clear
 
echo "Services will be stopped now" | tee -a $LOG_FILE

echo "stopping kibana service" | tee -a $LOG_FILE
systemctl stop kibana.service
sleep 2

echo "stopping datareader service" | tee -a $LOG_FILE
systemctl stop datareader.service
sleep 2

echo "stopping elasticsearch service" | tee -a $LOG_FILE
systemctl stop elasticsearch.service 
sleep 3

clear

echo "***SERVICES_STATUS***" | tee -a $LOG_FILE
echo "-----------------------------------" | tee -a $LOG_FILE

echo "***ELASTICSEARCH-SERVICE***" | tee -a $LOG_FILE
systemctl status elasticsearch.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE

echo "***DATAREADER-SERVICE***" | tee -a $LOG_FILE
systemctl status datareader.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILEE

echo "***KIBANA-SERVICE***" | tee -a $LOG_FILE
systemctl status kibana.service  | grep "Active\b" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE

echo | tee -a $LOG_FILE
echo | tee -a $LOG_FILE


echo "All services stopped please reboot server if needed" | tee -a $LOG_FILE

sleep 5





clear

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/ANALYTICS_PRE-REBOOT-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;



