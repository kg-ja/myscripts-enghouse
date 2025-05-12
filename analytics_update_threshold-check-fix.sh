 
#!/bin/bash

# File Path
TARGET_FILE=/etc/cron.hourly/clean_ES_data.sh
SEARCH_LINE='lower_threshold=80'
SEARCH_LINE2='upper_threshold=90'


CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)



LOG_FILE=/tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME.log


# Function to get server details
get_server_info() {

# clear the screen to present the information
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

echo "***ELK_VERSION***" >> $LOG_FILE
 cat /opt/analytic/datareader/version_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /usr/share/kibana/version_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***ELASTICSEARCH_VERSION***" >> $LOG_FILE
curl -XGET $theIPaddress:9200 | grep "number" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -XGET $theIPaddress:9200 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE
# Check current thresholds
echo "CURRENT THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


}


update_threshold() {

echo "=======================================================================================" | tee -a $LOG_FILE
# Check current thresholds
echo "CURRENT THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "Backing up clean ES data script" | tee -a $LOG_FILE

cp $TARGET_FILE /tmp/clean_ES_data.sh-$(date +"%Y_%m_%d_%I_%M_%p")


echo "Changing threshold" | tee -a $LOG_FILE
# Use sed to replace the line
sed -i 's/lower_threshold=80/lower_threshold=75/g' $TARGET_FILE
sed -i 's/upper_threshold=90/upper_threshold=80/g' $TARGET_FILE


echo "=======================================================================================" | tee -a $LOG_FILE
# Check new thresholds
echo "NEW THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE


echo "Optimization in progress, please wait" | tee -a $LOG_FILE

/etc/cron.hourly/clean_ES_data.sh

sleep 15

echo "=======================================================================================" | tee -a $LOG_FILE

tail -10 /tmp/purge_analytic.log | tee -a $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE

echo "Threshold updated if default, please check status in an hour" | tee -a $LOG_FILE

}




# Main loop, will check if  file actually exist then if at least one thresholds are default

# clear the screen to present the information
  clear

echo "=======================================================================================" | tee -a $LOG_FILE
# Check if the file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Error: File not found: $TARGET_FILE" | tee -a $LOG_FILE
  exit 1
fi

echo "=======================================================================================" | tee -a $LOG_FILE

 
if grep -Fxq "$SEARCH_LINE" "$TARGET_FILE" || grep -Fxq "$SEARCH_LINE2" "$TARGET_FILE"; then
    
   get_server_info    
   clear
   echo "At least one threshold is default and configuration will be optimized" | tee -a $LOG_FILE
   
   update_threshold
   clear
   echo "Threshold values are now optimized" | tee -a $LOG_FILE

else  
    
   get_server_info
   clear
   echo "thresholds are not default, no action will be taken" | tee -a $LOG_FILE
      
fi





chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log



exit 0;
