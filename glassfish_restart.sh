#!/bin/bash


CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

LOG_FILE=/tmp/glassfish-SERVICE-$HOST_NAME.log




check_glassfish() {

clear

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "=======================================================================================" | tee -a $LOG_FILE

# Check the status of glassfish service
echo "Checking glassfish service status..." | tee -a $LOG_FILE
STATUS_OUTPUT=$(systemctl status glassfish 2>&1)

if echo "$STATUS_OUTPUT" | grep -q "Active: active" ; then
    echo "❌ glassfish service is in a active state and will be stopped." | tee -a $LOG_FILE
    
	systemctl stop glassfish
	
    # Find glassfish process IDs and kill them
    echo "Searching for glassfish processes..." | tee -a $LOG_FILE
    PIDS=$(pgrep -f '/usr/lib/jvm/' | xargs)

   if [[ -n "$PIDS" ]]; then
	    echo "PIDS=[$PIDS]" | tee -a $LOG_FILE   
        echo "Killing glassfish process(es): $PIDS" | tee -a $LOG_FILE        
        kill -9 $PIDS
        echo "Killed process $PIDS" | tee -a $LOG_FILE
        sleep 5
    else
        echo "No glassfish processes found." | tee -a $LOG_FILE
		sleep 3
    fi

    # Restart glassfish service
    echo "Restarting glassfish service..." | tee -a $LOG_FILE
    systemctl restart glassfish 
    
	sleep 5
    # Confirm status
    NEW_STATUS=$(systemctl status glassfish 2>&1)
    if echo "$NEW_STATUS" | grep -q "Active: active"; then
        echo "glassfish service restarted successfully." | tee -a $LOG_FILE
    else
        echo "Failed to restart glassfish service. Status: $NEW_STATUS" | tee -a $LOG_FILE
    fi
else
    echo "glassfish service is not in a active state." | tee -a $LOG_FILE
    echo "Current status:" | tee -a $LOG_FILE
    systemctl status glassfish | grep Active | tee -a $LOG_FILE
	echo "=======================================================================================" | tee -a $LOG_FILE
fi


echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"




if echo "$STATUS_OUTPUT" | grep -q "Active: inactive" ; then
    echo "❌ glassfish service is in a inactive state." | tee -a $LOG_FILE
    
	
    # Find glassfish process IDs and kill them
    echo "Searching for glassfish processes..." | tee -a $LOG_FILE
    PIDS=$(pgrep -f '/usr/lib/jvm/' | xargs)

   if [[ -n "$PIDS" ]]; then
	    echo "PIDS=[$PIDS]" | tee -a $LOG_FILE   
        echo "Killing glassfish process(es): $PIDS" | tee -a $LOG_FILE        
        kill -9 $PIDS
        echo "Killed process $PIDS" | tee -a $LOG_FILE
        sleep 5
    else
        echo "No glassfish processes found." | tee -a $LOG_FILE
		sleep 3
    fi

    # Restart glassfish service
    echo "Restarting glassfish service..." | tee -a $LOG_FILE
    systemctl restart glassfish 
    
	sleep 5
    # Confirm status
    NEW_STATUS=$(systemctl status glassfish 2>&1)
    if echo "$NEW_STATUS" | grep -q "Active: active"; then
        echo "glassfish service restarted successfully." | tee -a $LOG_FILE
    else
        echo "Failed to restart glassfish service. Status: $NEW_STATUS" | tee -a $LOG_FILE
    fi
else
    echo "glassfish service is not in a inactive state." | tee -a $LOG_FILE
    echo "Current status:" | tee -a $LOG_FILE
    systemctl status glassfish | grep Active | tee -a $LOG_FILE
	echo "=======================================================================================" | tee -a $LOG_FILE
fi


echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"



}

# main menu

clear

echo "The script is running please wait..." | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

echo | tee -a "$LOG_FILE"

systemctl status bnetpps | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"

echo | tee -a "$LOG_FILE"

sleep 1

echo "Restarting pps" | tee -a $LOG_FILE

systemctl restart bnetpps

sleep 3

echo "Restarting pps completed" | tee -a $LOG_FILE

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

echo "Stopping glassfish" | tee -a $LOG_FILE

systemctl stop glassfish

echo | tee -a "$LOG_FILE"

echo | tee -a "$LOG_FILE"

check_glassfish

echo | tee -a "$LOG_FILE"

echo | tee -a "$LOG_FILE"

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/glassfish-SERVICE-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

echo | tee -a "$LOG_FILE"

echo | tee -a "$LOG_FILE"


echo "The script has completed please send log loacated in /tmp starting with glassfish-SERVICE to support ..." | tee -a $LOG_FILE


exit 0;