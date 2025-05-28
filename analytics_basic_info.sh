#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
YEAR=$(date +"%Y")
PREV_YEAR=$(date +"%Y" -d "last year")

LOG_FILE=/tmp/ANALYTICS_LOG_INFO-$HOST_NAME.log

clear


echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo | tee -a "$LOG_FILE"
echo "Script running, please wait" 
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

echo "HOSTS FILE" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/hosts >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
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


echo "***MEMORY-PRINOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
top -b -o %MEM | head -n 16 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CPU-PRINTOUT***" >> $LOG_FILE
top -b -o %CPU | head -n 16 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE


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


echo "***TOTAL-SHARDS***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/stats?filter_path=indices.shards.total  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "***MAX/TOTAL-SHARD-PER-NODE***" >> $LOG_FILE
echo "That setting is also set to -1 by default soemtimes, which means that there is no limit as to how many shards of a given index can be hosted on a specific data node" >> $LOG_FILE
echo "Thats if no max shard per node set" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***MAX-SHARD-PER-NODE***" >> $LOG_FILE
curl -s -XGET "$theIPaddress:9200/_cluster/settings?include_defaults=true&pretty=true" | grep "max_shards_per_node"  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***TOTAL-SHARD-PER-NODE***" >> $LOG_FILE
curl -s -XGET "$theIPaddress:9200/_cluster/settings?include_defaults=true&pretty=true" | grep "total_shards_per_node">> $LOG_FILE




echo "=======================================================================================" >> $LOG_FILE

echo "***CLUSTER-HEALTH***" >> $LOG_FILE
curl -s $theIPaddress:9200/_cat/health?v  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s $theIPaddress:9200/_cluster/health?pretty=true >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/allocation/explain?pretty >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***ELASTICSEARCH-INFO***" >> $LOG_FILE
cat /etc/elasticsearch/elasticsearch.yml >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SERVICES_STATUS***" >> $LOG_FILE
echo "-----------------------------------" >> $LOG_FILE

echo "***ELASTICSEARCH-SERVICE***" >> $LOG_FILE
systemctl status elasticsearch.service  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***DATAREADER-SERVICE***" >> $LOG_FILE
systemctl status datareader.service  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***KIBANA-SERVICE***" >> $LOG_FILE
systemctl status kibana.service  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "***RABBITMQ-SERVICE***" >> $LOG_FILE
systemctl status rabbitmq-server | grep "Active\b" >> $LOG_FILE 
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***RABBITMQ-QUEUES***" >> $LOG_FILE
rabbitmqctl list_queues >> $LOG_FILE 
echo "=======================================================================================" >> $LOG_FILE




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

echo "*INTERFACE-CHECK*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
echo "*ETH-0*" >> $LOG_FILE
cat ifcfg-eth0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-1*" >> $LOG_FILE
cat ifcfg-eth1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-2*" >> $LOG_FILE
cat ifcfg-eth2 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*INTERFACE-CHECK-COTS*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
echo "*MGMT*" >> $LOG_FILE
cat ifcfg-mgmt >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SYSTEM-UPTIME-INFO***" >> $LOG_FILE
uptime >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
who -b >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***TIME-SYNC***" >> $LOG_FILE
cat /etc/chrony.conf >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
timedatectl status >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***TIME-SOURCES-TRACKING***" >> $LOG_FILE
chronyc sources >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
chronyc tracking >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
chronyc ntpdata >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***DATA-READER_LOG-INFO***" >> $LOG_FILE
tail -50 /var/log/analytic/datareader.log  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***MAX-SHARDS-INFO-DATA-READER-LOG***" >> $LOG_FILE
cat /var/log/analytic/datareader.log | grep "maximum shards open" | sort | tail -15   >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***PARSE-ERRORS-INFO-DATA-READER-LOG***" >> $LOG_FILE
cat /var/log/analytic/datareader.log | grep "failed to parse"  | sort | tail -15  >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***TOTAL-SHARDS-INFO***" >> $LOG_FILE
curl -s $theIPaddress:9200/_cat/shards?v | wc -l  >> $LOG_FILE


echo " =======================================================================================" >> $LOG_FILE

echo "***UNASSIGNED-SHARD-INFO***" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason| grep UNASSIGNED >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***RABBITMQ-LOG-INFO***" >> $LOG_FILE
tail -50 /var/log/rabbitmq/rabbit@analytic.log >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***ELASTICSEARCH-GC-LOG-INFO***" >> $LOG_FILE
tail -50 /var/log/elasticsearch/gc.log >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***TOTAL-PERFORMANCES-INDICES***" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/*performance-* | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "TOTAL stats-dialogic-performance-indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-* | wc -l  >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======stats-dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "TOTAL dialogic-performance-indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-* | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-performance count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-performance count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$PREV_YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "*TOTAL dialogic-sbc-indices*" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-* | wc -l  >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-sbc-indices count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-sbc-indices count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$PREV_YEAR* | wc -l  >> $LOG_FILE




echo "=======================================================================================" >> $LOG_FILE
echo "===============================dialogic-sbc==========================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc* | sort | head -10 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc* | sort | tail -10 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "===============================dialogic-performance==========================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance* | sort | head -10  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance* | sort | tail -10 >> $LOG_FILE




echo "=======================================================================================" >> $LOG_FILE
echo "===============================stats-dialogic-performance==========================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | sort | head -20  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | sort | tail -10 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE



echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "===============================DIALOGIC-TEMPLATE==========================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_template/template_1?pretty=true >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "===============================APPLICATION_LIST==========================================" >> $LOG_FILE
echo "***count of all installed packages***" >> $LOG_FILE
yum list installed | wc -l >> $LOG_FILE
echo "***all installed packages names***" >> $LOG_FILE
yum list installed >> $LOG_FILE

clear


chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/ANALYTICS_LOG_INFO-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

echo "This script has completed, please check /tmp folder for ANALYTICS_LOG_INFO-* log to send to support" 

exit 0;



