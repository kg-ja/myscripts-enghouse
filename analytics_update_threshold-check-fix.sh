#!/bin/bash

# File Path
TARGET_FILE=/etc/cron.hourly/clean_ES_data.sh
TARGET_FILE2=/opt/analytic/datareader/service/config/default.json
SEARCH_LINE='lower_threshold=80'
SEARCH_LINE2='upper_threshold=90'
SEARCH_LINE3='"sendStatisticsToES": true'

YEAR=$(date +"%Y")
PREV_YEAR=$(date +"%Y" -d "last year")


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
echo | tee -a "$LOG_FILE"
dmidecode -t memory | grep -i 'Size:' | grep -v 'No Module Installed' | grep -i 'MB'  | awk '{sum += $2} END {print sum, "MB"}' >> $LOG_FILE
echo | tee -a "$LOG_FILE"
dmidecode -t memory | grep -i 'Size:' | grep -v 'No Module Installed' | grep -i 'GB'  | awk '{sum += $2} END {print sum, "GB"}' >> $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -k >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
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
curl -s -XGET $theIPaddress:9200 | grep "number" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
# Check current thresholds
echo "CURRENT THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Check stats
echo "=======================================================================================" >> $LOG_FILE
cat /opt/analytic/datareader/service/config/default.json | grep "sendStatisticsToES" | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

}



get_indices_info() {

echo "***TOTAL-SHARDS***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/stats?filter_path=indices.shards.total  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
echo >> $LOG_FILE
echo "***TOTAL-PERFORMANCES-INDICES***" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "dialogic-performance" | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "TOTAL stats-dialogic-performance-indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "stats-dialogic-performance" | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "TOTAL dialogic-performance-indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "^dialogic-performance" | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "*TOTAL dialogic-sbc-indices*" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "dialogic-sbc" | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-sbc-indices count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-sbc-indices count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$PREV_YEAR* | wc -l  >> $LOG_FILE



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

echo "Threshold updated if default, please check status in an hour, script will continue" | tee -a $LOG_FILE

}

update_stats() {

echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE

# Check current stats setup
echo "DEFAULT CONFIG JSON" | tee -a $LOG_FILE

cat /opt/analytic/datareader/service/config/default.json | grep "sendStatisticsToES" | tee -a $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"


echo "Backing up data reader service config file" | tee -a $LOG_FILE

cp $TARGET_FILE2 /tmp/default.json-$(date +"%Y_%m_%d_%I_%M_%p")

# change stats in default json
sed -i 's/"sendStatisticsToES": true/"sendStatisticsToES": false/g' $TARGET_FILE2

# delete all stats-dialogic-performance
curl -s -XDELETE $theIPaddress:9200/stats-dialogic-performance-*


#restart datareader srvice
echo | tee -a "$LOG_FILE"
echo "Restarting data reader service" | tee -a $LOG_FILE
systemctl restart datareader
echo | tee -a "$LOG_FILE"

sleep 5

echo | tee -a "$LOG_FILE"
systemctl status datareader >> $LOG_FILE

# Check new stats setup
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "CURRENT CONFIG JSON" | tee -a $LOG_FILE

cat /opt/analytic/datareader/service/config/default.json | grep "sendStatisticsToES" | tee -a $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE


}




# Main loop, will check if  file actually exist then if at least one thresholds are default

# clear the screen to present the information
  clear
  
  get_server_info

echo "=======================================================================================" | tee -a $LOG_FILE

# Check if the file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Error: File not found: $TARGET_FILE" | tee -a $LOG_FILE
  exit 1
fi

echo "=======================================================================================" | tee -a $LOG_FILE

 
if grep -Fxq "$SEARCH_LINE" "$TARGET_FILE" || grep -Fxq "$SEARCH_LINE2" "$TARGET_FILE"; then   
     
   clear
   echo | tee -a "$LOG_FILE"
   echo "=======================================================================================" | tee -a $LOG_FILE 
   echo "At least one threshold is default and configuration will be optimized" | tee -a $LOG_FILE
    echo "=======================================================================================" | tee -a $LOG_FILE 
   
   update_threshold
   
   sleep 10
   
   clear
   echo | tee -a "$LOG_FILE"
   echo "Threshold values are now optimized" | tee -a $LOG_FILE

else     
  
   
   echo | tee -a "$LOG_FILE"
   echo "thresholds are not default, no action will be taken" | tee -a $LOG_FILE
      
fi



if grep -q "$SEARCH_LINE3" "$TARGET_FILE2" ; then

   echo | tee -a "$LOG_FILE"
   echo "=======================================================================================" | tee -a $LOG_FILE      
   echo "statistics are set to send and will be adjusted" | tee -a $LOG_FILE 
    echo "=======================================================================================" | tee -a $LOG_FILE   
   echo | tee -a "$LOG_FILE"  

   update_stats
   
   sleep 5 
   echo | tee -a "$LOG_FILE"
   echo "statistics setting have been optimized " | tee -a $LOG_FILE  
   
   

else     
   
   
   echo | tee -a "$LOG_FILE"
   echo "statistics are not being sent, no action will be taken" | tee -a $LOG_FILE
   echo | tee -a "$LOG_FILE"
   
   
      
fi



get_indices_info





chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

sleep 5

clear

echo "This script has completed, please check /tmp folder for CLEANDATA-THRESHOLD-UPDATE-* log to send to support" 


exit 0;
