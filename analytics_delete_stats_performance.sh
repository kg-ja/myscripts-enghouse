 
#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
theIPaddress=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
NumtoDelete=100

YEAR=$(date +"%Y")
PREV_YEAR=$(date +"%Y" -d "last year")

default_prev_year=yes


LOG_FILE=/tmp/DELETE-STATSPERFORMANCE-$HOST_NAME.log



# Function to get server details
get_server_info() {

# clear the screen to present the information
  clear

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE

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


echo "***TOTAL-SHARDS***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/stats?filter_path=indices.shards.total  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

}


# Function to get indices stats details
get_indices_info() {

echo | tee -a "$LOG_FILE"

echo "***TOTAL-SHARDS***" >> $LOG_FILE
echo >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cluster/stats?filter_path=indices.shards.total  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo | tee -a "$LOG_FILE"
echo "***TOTAL-PERFORMANCES-INDICES***" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "dialogic-performance" | wc -l | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo "TOTAL stats-dialogic-performance-indices" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "stats-dialogic-performance" | wc -l | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILEE
echo "=======stats-dialogic-performance count for current year===============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo "=======stats-dialogic-performance count from previous year==============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo "TOTAL dialogic-performance-indices" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "^dialogic-performance" | wc -l | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
echo "=======dialogic-performance count for current year===============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo "=======dialogic-performance count from previous year==============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-performance-$PREV_YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo "*TOTAL dialogic-sbc-indices*" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "dialogic-sbc" | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======dialogic-sbc-indices count for current year===============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$YEAR* | wc -l  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======dialogic-sbc-indices count from previous year==============================" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/dialogic-sbc-$PREV_YEAR* | wc -l  >> $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

}




delete_indices_info() {

echo | tee -a "$LOG_FILE"

echo "stats-dialogic-performance indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "stats-dialogic-performance indices to delete" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | sort | head -$indices_delete>> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


curl -s $theIPaddress:9200/_cat/indices/stats-dialogic-performance-*?h=index \
| sort \
| head -n $indices_delete \
| while read index; do
    echo "Deleting index: $index" | tee -a $LOG_FILE
    curl -XDELETE $theIPaddress:9200/$index
done

sleep 2
clear
echo | tee -a "$LOG_FILE"
echo "Indices deleted" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" >> $LOG_FILE
echo "stats-dialogic-performance indices" >> $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance* | wc -l >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"


}



delete_indices_prev_year() {

curl -s $theIPaddress:9200/_cat/indices/stats-dialogic-performance-PREV_YEAR*?h=index \
| while read index; do
    echo "Deleting index: $index" | tee -a $LOG_FILE
    curl -XDELETE $theIPaddress:9200/$index
done
sleep 2
clear
echo | tee -a "$LOG_FILE"
echo "Indices from last year deleted" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "TOTAL stats-dialogic-performance-indices" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/shards?h=index,shard,prirep,state | grep "stats-dialogic-performance" | wc -l | tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILEE
echo "=======stats-dialogic-performance count for current year===============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo "=======stats-dialogic-performance count from previous year==============================" | tee -a $LOG_FILE
curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l  | tee -a $LOG_FILE

echo "---------------------------------------------------------------------------------------" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
}


# Function to confirm if the entered information is correct
confirm_info() {

   # clear the screen to present the information
    clear
    echo "You entered the following information:"
    echo "The amount of stats-performance dialogic indices to delete: $indices_delete"   
    read -rp "Is the information correct? (yes/no): " confirm
}




user_delete_info() {


atttempts=3

while [ $attempts -gt 0 ]; do

# Query the user on what to delete
  echo | tee -a "$LOG_FILE"
  index_count=$(curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-* | wc -l )
  indices_half=$(( index_count / 2 ))
  read -rp "Enter the amount of stats-performance indices you want to delete( TOTAL COUNT: $index_count) [Default: $indices_half]: " indices_delete


if [ -z "$indices_delete" ]; then
    indices_delete="$indices_half"
fi

# Test whether reply is a (possibly‑signed) whole number and less than index_count
    if [[ $indices_delete =~ ^[0-9]+$ && "$indices_delete" -le "$index_count"  ]]; then
        echo "valid input" >> $LOG_FILE
		break
    else
	     atttempts=$((atttempts - 1))
		 if [ $attempts -gt 0 ]; then
            echo | tee -a "$LOG_FILE"
            echo "Inavlid input. Number need to be a whole number and less than or equal to $index_count. You have $atttempts attempt(s) left." | tee -a $LOG_FILE
        else
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
            exit 1
         fi

    fi


done

echo | tee -a "$LOG_FILE"

}



# Main loop, will ask for information twice if needed
clear
echo "This script will help with deleting old statistic indices from your data node" | tee -a $LOG_FILE
sleep 1
get_server_info

# Display total performace indices
  echo "Please see printout of below of amount of stat-performance indices" | tee -a $LOG_FILE
  get_indices_info

# Query the user on what to delete
  index_count_prev_year=$(curl -s -XGET $theIPaddress:9200/_cat/indices/stats-dialogic-performance-$PREV_YEAR* | wc -l )
  read -rp "Do you wish to delete all stats-performance indices from last year(amount: $index_count_prev_year ) [Default: $default_prev_year]: " indices_prev_year


if [ -z "$indices_prev_year" ]; then
    indices_prev_year="$default_prev_year"
fi



if [[ "$indices_prev_year" == "yes" || "$indices_prev_year" == "YES" || "$indices_prev_year" == "y"  ]]; then
echo "valid input: $indices_prev_year " >> $LOG_FILE
delete_indices_prev_year

elif [[ "$indices_prev_year" == "no" || "$indices_prev_year" == "NO" || "$indices_prev_year" == "n"  ]]; then
echo "valid input: $indices_prev_year " >> $LOG_FILE

else

echo "Invalid input: $indices_prev_year , exiting" | tee -a $LOG_FILE
exit 1

fi

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

attempts=3

while [ $attempts -gt 0 ]; do
    
    user_delete_info
    confirm_info


    if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
        echo "Information confirmed." | tee -a $LOG_FILE
        delete_indices_info
        break
    else
        attempts=$((attempts - 1))
        if [ $attempts -gt 0 ]; then
            echo "Please enter the information again. You have $attempts attempt(s) left."
        else
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
            exit 1
        fi
    fi
done

get_indices_info

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/DELETE-STATSPERFORMANCE-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log



exit 0;
