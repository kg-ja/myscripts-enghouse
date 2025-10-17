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
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)



LOG_FILE=/tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME.log


# Function to get server details
get_server_info() {


echo "=======================================================================================" > $LOG_FILE
echo "***$CURRENT_TIMESTAMP - START OF LOG***" >> $LOG_FILE
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
echo "INTERFACE NAME OF THIS SYSTEM IS: $iface" >> $LOG_FILE
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

echo "*** HW/VM -License-Platform-Details***" >> $LOG_FILE

dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/os-release >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***KERNEL-VERSION***" >> $LOG_FILE
uname -r >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***KEXEC-VERSION***" >> $LOG_FILE
rpm -qa | grep kexec >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE

echo >> $LOG_FILE

echo "***Full summary of available and used disk space usage of the file system***" >> $LOG_FILE
echo "***USED SPACE ABOVE 80% NEEDS ATTENTION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
df -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "===================================/data/nodes-size=======================================" >> $LOG_FILE

du -sh /data/nodes >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE


echo "***STORAGE-INFO***" >> $LOG_FILE

du -h / --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --max-depth=1 | sort -rh | head -20 >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE

echo >> $LOG_FILE


}



get_indices_info() {

echo >> $LOG_FILE

echo "ANALYTICS-PLATFORM-INFORMATION" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***ANALTICS-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***NODE-INFO***" >> $LOG_FILE
curl -s $theIPaddress:9200/_cat/nodes?v  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE
echo "***CLEAN-DATA-SCRIPT-LIMIT***" >> $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= >> $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

# Check current stats setup
echo "DEFAULT CONFIG JSON"  >> $LOG_FILE

cat /opt/analytic/datareader/service/config/default.json | grep "sendStatisticsToES"  >> $LOG_FILE

echo "======================================================================================="  >> $LOG_FILE

echo >> $LOG_FILE

echo >> $LOG_FILE
echo "***CLUSTER-HEALTH***" >> $LOG_FILE
curl -s $theIPaddress:9200/_cat/health?v  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s $theIPaddress:9200/_cluster/health?pretty=true >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***CLUSTER-ALLOCATION***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/allocation/explain?pretty >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo >> $LOG_FILE
echo >> $LOG_FILE

echo "***TOTAL-SHARDS***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/stats?filter_path=indices.shards.total  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
echo >> $LOG_FILE
echo "***TOTAL-PERFORMANCES-INDICES ON THIS NODE***" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/*performance-* | wc -l >> $LOG_FILE >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "TOTAL stats-dialogic-performance-indices on this node" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-* | wc -l  >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "TOTAL dialogic-performance-indices on this node" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-* | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "*TOTAL dialogic-sbc-indices on this node*" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-* | wc -l  >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-sbc-indices count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-sbc-indices count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$PREV_YEAR* | wc -l  >> $LOG_FILE


echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"


}


update_threshold() {

echo | tee -a "$LOG_FILE"
echo "Checki thresholds" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"

echo "=======================================================================================" | tee -a $LOG_FILE
# Check current thresholds
echo "CURRENT THRESHOLDS" | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep lower_threshold= | tee -a $LOG_FILE
cat /etc/cron.hourly/clean_ES_data.sh | grep upper_threshold= | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE


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

echo | tee -a "$LOG_FILE"


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


#restart datareader srvice
echo | tee -a "$LOG_FILE"
echo "Restarting data reader service" | tee -a $LOG_FILE
systemctl restart datareader
echo | tee -a "$LOG_FILE"

sleep 5

echo | tee -a "$LOG_FILE"
echo "=======================================================================================" >> $LOG_FILE
echo "Checking datareader status" >> $LOG_FILE
echo >> $LOG_FILE
systemctl status datareader >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

# Check new stats setup
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE
echo "CURRENT CONFIG JSON" | tee -a $LOG_FILE

cat /opt/analytic/datareader/service/config/default.json | grep "sendStatisticsToES" | tee -a $LOG_FILE

echo "=======================================================================================" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"


}



check_stats-performance_indices() {
echo | tee -a "$LOG_FILE"

# delete all stats-dialogic-performance
if [ "$(curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-* | wc -l)" -eq 0 ]; then
    echo "There are no stats-performance indices to delete" | tee -a $LOG_FILE
else
    echo "stats-performance indices are present and will now be deleted" | tee -a $LOG_FILE
    curl -s -XDELETE $theIPaddress:9200/stats-dialogic-performance-*
    sleep 1
    echo "all stats-performace indices deleted" | tee -a $LOG_FILE
fi

}


check_kibana_failed() {

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE

# Check the status of kibana service
echo "Checking Kibana service status..." | tee -a $LOG_FILE
STATUS_OUTPUT=$(systemctl status kibana 2>&1)

if echo "$STATUS_OUTPUT" | grep -q "Active: failed"; then
    echo "❌ Kibana service is in a failed state." | tee -a $LOG_FILE

    # Find Kibana process IDs and kill them
    echo "Searching for Kibana processes..." | tee -a $LOG_FILE
    PIDS=$(pgrep -f '/usr/share/kibana/' | xargs)

   if [[ -n "$PIDS" ]]; then
	    echo "PIDS=[$PIDS]" | tee -a $LOG_FILE   
        echo "Killing Kibana process(es): $PIDS" | tee -a $LOG_FILE        
        kill -9 $PIDS
        echo "Killed process $PIDS" | tee -a $LOG_FILE
        sleep 5
    else
        echo "No Kibana processes found." | tee -a $LOG_FILE
    fi

    # Restart Kibana service
    echo "Restarting Kibana service..." | tee -a $LOG_FILE
    systemctl restart kibana 
    
	sleep 5
    # Confirm status
    NEW_STATUS=$(systemctl status kibana 2>&1)
    if echo "$NEW_STATUS" | grep -q "Active: active"; then
        echo "Kibana service restarted successfully." | tee -a $LOG_FILE
    else
        echo "Failed to restart Kibana service. Status: $NEW_STATUS" | tee -a $LOG_FILE
    fi
else
    echo "Kibana service is not in a failed state." | tee -a $LOG_FILE
    echo "Current status:" | tee -a $LOG_FILE
    systemctl status kibana | grep Active | tee -a $LOG_FILE
	echo "=======================================================================================" | tee -a $LOG_FILE
fi


echo | tee -a "$LOG_FILE"

}

check_elasticsearch_failed() {

echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE

# Check the status of elasticsearch service
echo "Checking elasticsearch service status..." | tee -a $LOG_FILE
STATUS_OUTPUT=$(systemctl status elasticsearch 2>&1)


if echo "$STATUS_OUTPUT" | grep -qE "Active: (failed|inactive)"; then

    echo "❌ Elasticsearch service is failed or inactive." | tee -a "$LOG_FILE"

    # Find elasticsearch process IDs and kill them
    echo "Searching for elasticsearch processes..." | tee -a $LOG_FILE
    PIDS=$(pgrep -f '/usr/share/elasticsearch/' | xargs)

   if [[ -n "$PIDS" ]]; then
	    echo "PIDS=[$PIDS]" | tee -a $LOG_FILE   
        echo "Killing elasticsearch process(es): $PIDS" | tee -a $LOG_FILE        
        kill -9 $PIDS
        echo "Killed process $PIDS" | tee -a $LOG_FILE
        sleep 5
    else
        echo "No elasticsearch processes found." | tee -a $LOG_FILE
    fi

    # Restart elasticsearch service
    echo "Restarting elasticsearch service..." | tee -a $LOG_FILE
    systemctl restart elasticsearch 
    
	sleep 5
    # Confirm status
    NEW_STATUS=$(systemctl status elasticsearch 2>&1)
    if echo "$NEW_STATUS" | grep -q "Active: active"; then
        echo "elasticsearch service restarted successfully." | tee -a $LOG_FILE
    else
        echo "Failed to restart elasticsearch service. Status: $NEW_STATUS" | tee -a $LOG_FILE
    fi
else
    echo "elasticsearch service is not in a failed or inactive state." | tee -a $LOG_FILE
    echo "Current status:" | tee -a $LOG_FILE
    systemctl status elasticsearch | grep Active | tee -a $LOG_FILE
	echo "=======================================================================================" | tee -a $LOG_FILE
fi


echo | tee -a "$LOG_FILE"

}



# Main loop, will check if  file actually exist then if at least one thresholds are default

# clear the screen to present the information
  clear
  
  echo "Script running, please wait" 
  
  echo | tee -a "$LOG_FILE"
  
  get_server_info
  get_indices_info

echo "=======================================================================================" | tee -a $LOG_FILE

# Check if the file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Error: File not found: $TARGET_FILE" | tee -a $LOG_FILE
   echo | tee -a "$LOG_FILE"
  echo "Please advise support of missing file" | tee -a $LOG_FILE
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
   echo "thresholds are not default, no action will be taken for this item" | tee -a $LOG_FILE
      
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
   echo "statistics are not being sent, no action will be taken for this item" | tee -a $LOG_FILE
   echo | tee -a "$LOG_FILE"
   
   
      
fi


check_stats-performance_indices

get_indices_info

check_kibana_failed

check_elasticsearch_failed

sleep 3

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/CLEANDATA-THRESHOLD-UPDATE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

sleep 3

clear

echo "This script has completed, please check /tmp folder for CLEANDATA-THRESHOLD-UPDATE-* log to send to support" 


exit 0;
