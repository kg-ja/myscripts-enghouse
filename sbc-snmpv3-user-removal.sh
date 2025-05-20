#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

FILE=/etc/snmp/snmpd.conf
FILE2=/var/lib/net-snmp/snmpd.conf

allsnmpv3users=all
nosnmpv3users=none

LOG_FILE=/tmp/SBC_SNMPV3-USER-DELETE_INFO-$HOST_NAME.log





# Function to get server details
get_server_info() {

# clear the screen to present the information
  clear

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***-SBC-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "*** HW/VM -SBC-License-Platform-Details***" >> $LOG_FILE

dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


}

# Function to get user to delete
get_snmpv3user() {

clear
echo "A display of all users will be presented "
sleep 2
clear

echo "CURRENT SNMPv3 USERS" | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE
echo "rouser\| rwuser count" | tee -a $LOG_FILE
cat /etc/snmp/snmpd.conf | grep "rouser\| rwuser" | wc -l | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE
echo " Specific Users: " | tee -a $LOG_FILE
cat /etc/snmp/snmpd.conf | grep "rouser\| rwuser"| tee -a $LOG_FILE
echo "=======================================================================================" | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
echo "usmUser  count" | tee -a $LOG_FILE
cat /var/lib/net-snmp/snmpd.conf | grep -i usmUser | wc -l | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE
cat /var/lib/net-snmp/snmpd.conf | grep -i usmUser | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE

}

# function to prompt user for snmpv3 user to delete and checks if it exists
prompt_snmpv3user_del() {


echo | tee -a "$LOG_FILE"
# Prompt for which users to delete
  read -p "Please enter the user you want to delete, you can also enter all for all users [Default: $nosnmpv3users]: " user_snmpv3

if [ -z "$user_snmpv3" ]; then
    user_snmpv3="$nosnmpv3users"
	return 0
fi

if [ "$user_snmpv3" = "none" ]; then
    echo "You have chosen to not delete any users" | tee -a $LOG_FILE	
	return 0
fi

if [[ "$user_snmpv3" = "all" || "$user_snmpv3" = "ALL" ]]; then
echo | tee -a "$LOG_FILE"
echo "You have chosen to delete all users"
sleep 1
echo | tee -a "$LOG_FILE"
return 0
fi

if grep -E "rouser|rwuser" /etc/snmp/snmpd.conf | grep -q "$user_snmpv3" && \
   grep -i "usmUser" /var/lib/net-snmp/snmpd.conf | grep -q "$user_snmpv3"; then  
    echo | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"	
    echo "$user_snmpv3 found in both files, indicates user was created correctly"
	sleep 2
	return 0

elif grep -E "rouser|rwuser" /etc/snmp/snmpd.conf | grep -q "$user_snmpv3" || \
   grep -i "usmUser" /var/lib/net-snmp/snmpd.conf | grep -q "$user_snmpv3"; then  
   echo | tee -a "$LOG_FILE"
   echo | tee -a "$LOG_FILE"   
   echo "$user_snmpv3 is found in only one of two files , which indicates user was not created correctly" | tee -a $LOG_FILE
   sleep 3
	
else
    echo | tee -a "$LOG_FILE"
	echo | tee -a "$LOG_FILE"
    echo "$user_snmpv3 not found , please review current users in display, script will exit" | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
    exit 1
fi


echo | tee -a "$LOG_FILE"
}




# Function to confirm if the entered information is correct
confirm_info() {

 # clear the screen to present the information
    clear

 echo "You entered the following information:"
    echo "SNMPv3 user to delete: $user_snmpv3"  
 read -p "Is the information correct? (yes/no): " confirm
 echo | tee -a "$LOG_FILE"
}

    

snmpfile_backup() {

echo | tee -a "$LOG_FILE"
echo "Backing up $FILE and $FILE2" | tee -a $LOG_FILE
cp /var/lib/net-snmp/snmpd.conf /var/lib/net-snmp/snmpd.conf.varbackup-$(date +"%Y_%m_%d_%I_%M_%p")
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.etcbackup-$(date +"%Y_%m_%d_%I_%M_%p")

sleep 2
echo "Backing up files completed" | tee -a $LOG_FILE
echo "======================================================================================="  | tee -a $LOG_FILE
echo | tee -a "$LOG_FILE"
}


snmpservices_start() {
echo | tee -a "$LOG_FILE"
echo "starting process snmpd" | tee -a $LOG_FILE
   service snmpd start
   sleep 3
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
}


snmpservices_stop() {
echo | tee -a "$LOG_FILE"
echo "stopping process snmpd" | tee -a $LOG_FILE
   service snmpd stop
   sleep 1

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
}





# Function to delete snmpv3 user
snmpv3user_delete() {



 if [[ "$user_snmpv3" = "all" || "$user_snmpv3" = "ALL" ]]; then
     
    snmpservices_stop
    snmpfile_backup
    echo "Deleting all SNMPv3 users from $FILE and $FILE2..." | tee -a $LOG_FILE
    sed -i '/^rouser /d' $FILE | tee -a $LOG_FILE
    sed -i '/^usmUser /d' $FILE2 | tee -a $LOG_FILE
    echo "All users lines deleted." | tee -a $LOG_FILE
    snmpservices_start

  
   


 elif [ "$user_snmpv3" = "none" ]; then
         echo | tee -a "$LOG_FILE"
		 echo | tee -a "$LOG_FILE"
         echo "No users will be deleted. Exiting." | tee -a $LOG_FILE
		 echo | tee -a "$LOG_FILE"
		 echo | tee -a "$LOG_FILE"
         exit 1
		 		 
		 

 else
    snmpservices_stop
    snmpfile_backup
    echo "Deleting SNMPv3 user $user_snmpv3 from $FILE and $FILE2..." | tee -a $LOG_FILE
    sed -i "/^rouser $user_snmpv3/d" $FILE 
    sed -i "/\"$user_snmpv3\"/d" $FILE2
    snmpservices_start

    echo | tee -a "$LOG_FILE"
    echo "User $user_snmpv3 deleted." | tee -a $LOG_FILE
    echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
	echo | tee -a "$LOG_FILE"

fi


service snmpd status | tee -a $LOG_FILE

}




# Main loop, will ask for information twice if needed
attempts=3

while [ $attempts -gt 0 ]; do
    get_server_info
    get_snmpv3user
    prompt_snmpv3user_del
    confirm_info

    if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
        echo "Information confirmed."
        break
    else
        attempts=$((attempts - 1))
        if [ $attempts -gt 0 ]; then
            echo "Please enter the information again. You have $attempts attempt(s) left."
        else
            echo "You have exceeded the number of attempts. Exiting."
            exit 1
        fi
    fi
done


snmpv3user_delete

echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

sleep 3

get_snmpv3user

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SBC_SNMPV3-USER-DELETE_INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;
