 
#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
NumtoDelete=5


LOG_FILE=/tmp/DELETE-STATSPERFORMANCE-$HOST_NAME.log


echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE

echo "IP ADDRESS OF THIS SYSTEM IS: $theIPaddress" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "stats-dialogic-performance indices" >> $LOG_FILE
curl -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | sort | head -$NumtoDelete >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


curl -s $theIPaddress:9200/_cat/indices/stats-dialogic-performance-*?h=index \
| sort \
| head -n $NumtoDelete \
| while read index; do
    echo "Deleting index: $index" >> $LOG_FILE
    curl -XDELETE $theIPaddress:9200/$index
done


chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/DELETE-STATSPERFORMANCE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log



exit 0;
