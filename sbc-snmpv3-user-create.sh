#!/bin/bash

clear

# Default values
snmp_etc_config=/etc/snmp/snmpd.conf
snmp_varlib_config=/var/lib/net-snmp/snmpd.conf

default_hashAlgo=MD5
default_encrypto=DES

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

LOG_FILE=/tmp/SNMPv3-USER-$HOST_NAME.log


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

# Function to get snmp users
get_snmpv3user() {

echo "Please see below current snmpv3 users: "
sleep 1

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



create_snmpv3user() {

sleep 1
echo | tee -a "$LOG_FILE"
echo "You will now be prompted to enter details to create new SNMPv3 user"
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
    
 # Prompt the user for a SNMPv3 user
  read -p "Enter username for SNMPv3 user : " user_snmpv3


aattempt=3

while [ $aattempt -gt 0 ]; do

 echo | tee -a "$LOG_FILE"
 echo | tee -a "$LOG_FILE"
 # specifies the authentication password
  echo "Note: passwords are hidden during input" | tee -a $LOG_FILE
  read -s -p "Please enter password (minimum 8 characters) for SNMPv3 user : " userpw_snmpv3
    
	#check length of variable greater than or equal to 8
    if [ ${#userpw_snmpv3} -ge 8 ]; then
    echo | tee -a "$LOG_FILE"
    echo "Password accepted." | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
    break

    else
         aattempt=$((aattempt - 1))
         if [ $aattempt -gt 0 ]; then
            echo | tee -a "$LOG_FILE"
            echo "Password too short. Minimum characters is 8 enter the information again. You have $aattempt attempt(s) left." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
			echo | tee -a "$LOG_FILE"
        else
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
            exit 1
         fi
   fi

done

echo | tee -a "$LOG_FILE"

attemptss=3

while [ $attemptss -gt 0 ]; do

 echo | tee -a "$LOG_FILE"
 echo | tee -a "$LOG_FILE"
 # the password hashing algorithm
  echo | tee -a "$LOG_FILE"
  read -p "Please enter hashing algorithm in CAPS for SNMPv3 user MD5 or SHA [Default: $default_hashAlgo]: " user_hashAlgo

  if [ -z "$user_hashAlgo" ]; then
    user_hashAlgo="$default_hashAlgo"
    echo "hashing algorithm is $user_hashAlgo." | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
    break
  fi

    
    if [[ "$user_hashAlgo" == "MD5" || "$user_hashAlgo" == "SHA" ]]; then
       echo "valid input: $user_hashAlgo " | tee -a $LOG_FILE 
	   echo | tee -a "$LOG_FILE"
       break

    else
         attemptss=$((attemptss - 1))
         if [ $attemptss -gt 0 ]; then
            echo | tee -a "$LOG_FILE"
            echo "$user_hashAlgo is invalid, enter the information again. You have $attemptss attempt(s) left." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
			echo | tee -a "$LOG_FILE"
        else 
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
			echo | tee -a "$LOG_FILE"
            exit 1
         fi
   fi

done



echo | tee -a "$LOG_FILE"

attemptts=3

while [ $attemptts -gt 0 ]; do
  echo | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
 # specifies the encryption algorithm
  read -p "Please enter encryption algorithm for SNMPv3 user DES or AES [Default: $default_encrypto]: " user_encrypto

if [ -z "$user_encrypto" ]; then
    user_encrypto="$default_encrypto"
    echo "encryption algorith is $user_encrypto." | tee -a $LOG_FILE
	echo | tee -a "$LOG_FILE"
    break
fi

    
    if [[ "$user_encrypto" == "DES" || "$user_encrypto" == "AES" ]]; then
       echo "valid input: $user_encrypto " | tee -a $LOG_FILE 
	   echo | tee -a "$LOG_FILE"
       break

    else
         attemptts=$((attemptts - 1))
         if [ $attemptts -gt 0 ]; then
            echo | tee -a "$LOG_FILE"
            echo "$user_encrypto is invalid, enter the information again. You have $attemptts attempt(s) left." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
			echo | tee -a "$LOG_FILE"
        else
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
			echo | tee -a "$LOG_FILE"
			echo | tee -a "$LOG_FILE"
            exit 1
         fi
   fi

done







echo | tee -a "$LOG_FILE"
atttempts=3

while [ $atttempts -gt 0 ]; do
  echo | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  # specifies the encryption password
  echo "Note: passwords are hidden during input" | tee -a $LOG_FILE
  read -s -p "Please enter encryption password: " user_encrypto_pwd
    
    if [ ${#user_encrypto_pwd} -ge 8 ]; then
    echo | tee -a "$LOG_FILE"
    echo "Password accepted." | tee -a $LOG_FILE
    break

    else
         atttempts=$((atttempts - 1))
         if [ $atttempts -gt 0 ]; then
            echo | tee -a "$LOG_FILE"
            echo "Password too short. Minimum characters is 8 enter the information again. You have $atttempts attempt(s) left.." | tee -a $LOG_FILE
        else
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a $LOG_FILE
            exit 1
         fi
   fi

done

}


# Function to confirm if the entered information is correct
confirm_info() {

   # clear the screen to present the information
    clear
    echo "You entered the following information:"
    echo "SNMPv3 username: $user_snmpv3"   
    echo "SNMPv3 user authentication password: $userpw_snmpv3"
    echo "SNMPv3 hashing algorithm: $user_hashAlgo"
    echo "SNMPv3 encryption password: $user_encrypto_pwd"   
    echo "SNMPv3 encryption algorithm: $user_encrypto" 
    read -p "Is the information correct? (yes/no): " confirm
}


# Main loop, will ask for information twice if needed
attempts=3

while [ $attempts -gt 0 ]; do
    get_server_info
    get_snmpv3user
    create_snmpv3user
    confirm_info

    if [[ "$confirm" == "yes" || "$confirm" == "y" ]]; then
        echo "Information confirmed." | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
        break
    else
        attempts=$((attempts - 1))
        if [ $attempts -gt 0 ]; then
            echo "Please enter the information again. You have $attempts attempt(s) left."
        else
            echo | tee -a "$LOG_FILE"
            echo "You have exceeded the number of attempts. Exiting." | tee -a "$LOG_FILE"
            exit 1
        fi
    fi
done

clear

service snmpd stop

echo "making a backup of configuration files , please wait" | tee -a $LOG_FILE

cp "$snmp_varlib_config" /var/lib/net-snmp/snmpd.conf.varbackup-$(date +"%Y_%m_%d_%I_%M_%p")

cp "$snmp_etc_config" /etc/snmp/snmpd.conf.etcbackup-$(date +"%Y_%m_%d_%I_%M_%p")

net-snmp-create-v3-user -ro -A $userpw_snmpv3 -a $user_hashAlgo -X $user_encrypto_pwd -x $user_encrypto $user_snmpv3

service snmpd start


clear 

echo "configuring the snmpv3 user , please wait" | tee -a $LOG_FILE
echo "---------------------------------------------" | tee -a $LOG_FILE

sleep 3


echo "snmpv3 user configuration is complete." | tee -a $LOG_FILE

echo "---------------------------------------------" | tee -a $LOG_FILE

# Final output (only if confirmed or after 2 attempts)
    echo "Final SNMPv3 Configuration:" | tee -a $LOG_FILE
    echo "SNMPv3 username: $user_snmpv3" | tee -a $LOG_FILE   
    echo "SNMPv3 hashing algorithm: $user_hashAlgo" | tee -a $LOG_FILE  
    echo "SNMPv3 encryption algorithm: $user_encrypto" | tee -a $LOG_FILE

get_snmpv3user
echo "---------------------------------------------" | tee -a $LOG_FILE
service snmpd status | tee -a $LOG_FILE

echo "---------------------------------------------" | tee -a $LOG_FILE
cd /etc/snmp/

echo "***/etc/snmp/ Files***" >> $LOG_FILE

ls -ltr >> $LOG_FILE

echo "---------------------------------------------"  >> $LOG_FILE

cd /var/lib/net-snmp/

echo "***/var/lib/net-snmp/ Files***" >> $LOG_FILE

ls -ltr >> $LOG_FILE

echo "---------------------------------------------" >> $LOG_FILE


chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SNMPv3-USER-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log


exit 0;
