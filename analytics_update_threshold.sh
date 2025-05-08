 
#!/bin/bash

# File Path
TARGET_FILE=/etc/cron.hourly/clean_ES_data.sh

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)


LOG_FILE=/tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME.log


echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE

echo "IP ADDRESS OF THIS SYSTEM IS: $theIPaddress" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


# Check if the file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Error: File not found: $TARGET_FILE" | tee -a $LOG_FILE
  exit 1
fi

echo "=======================================================================================" | tee -a $LOG_FILE
# Check current thresholds
echo "CURRENT THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



cp $TARGET_FILE /tmp/clean_ES_data.sh-$(date +"%Y_%m_%d_%I_%M_%p")


# Use sed to replace the line
sed -i 's/lower_threshold=80/lower_threshold=75/g' $TARGET_FILE
sed -i 's/upper_threshold=90/upper_threshold=80/g' $TARGET_FILE


echo "=======================================================================================" | tee -a $LOG_FILE
# Check new thresholds
echo "NEW THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE


/etc/cron.hourly/clean_ES_data.sh

sleep 15

echo "=======================================================================================" | tee -a $LOG_FILE

tail -10 /tmp/purge_analytic.log | tee -a $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE

echo "Threshold updated if default, please check status in an hour" 

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log



exit 0;
