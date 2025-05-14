#!/bin/bash

clear

# Default values
snmp_etc_config=/etc/snmp/snmpd.conf
snmp_varlib_config=/var/lib/net-snmp/snmpd.conf

default_hashAlgo=MD5
default_encrypto=DES

CURRENT_TIMESTAMP=`date`

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
cat /etc/snmp/snmpd.conf | grep "rouser\| rwuser"| tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE
cat /var/lib/net-snmp/snmpd.conf | grep -i user | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------"| tee -a $LOG_FILE

}



create_snmpv3user() {

sleep 1
echo "You will now be prompted to enter details to create new SNMPv3 user"
    
 # Prompt the user for a SNMPv3 user
  read -p "Enter username for SNMPv3 user : " user_snmpv3


 # specifies the authentication password
  read -p "Please enter password for SNMPv3 user : " userpw_snmpv3


 # the password hashing algorithm
  read -p "Please enter hashing algorithm in CAPS for SNMPv3 user MD5 or SHA [Default: $default_hashAlgo]: " user_hashAlgo

# Use the default hashing algorithm  if the user didn't provide input

if [ -z "$user_hashAlgo" ]; then
    user_hashAlgo="$default_hashAlgo"
fi

if [[ "$user_hashAlgo" == "MD5" || "$user_hashAlgo" == "SHA" ]]; then
echo "valid input: $user_hashAlgo " >> $LOG_FILE

else
echo "Invalid input: $user_hashAlgo , exiting" | tee -a $LOG_FILE
exit 1

fi



 # specifies the encryption algorithm
  read -p "Please enter encryption algorithm for SNMPv3 user DES or AES [Default: $default_encrypto]: " user_encrypto

# Use the default encryption algorithm  if the user didn't provide input

if [ -z "$user_encrypto" ]; then
    user_encrypto="$default_encrypto"
fi

if [[ "$user_encrypto" == "DES" || "$user_encrypto" == "AES" ]]; then
echo "valid input: $user_encrypto " >> $LOG_FILE

else

echo "Invalid input: $user_encrypto , exiting" | tee -a $LOG_FILE
exit 1

fi




 # specifies the encryption password
  read -p "Please enter encryption password: " user_encrypto_pwd



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

clear

service snmpd stop

echo "making a backup of configuration files , please wait" | tee -a $LOG_FILE

cp $snmp_varlib_config /var/lib/net-snmp/snmpd.conf.varbackup-$(date +"%Y_%m_%d_%I_%M_%p")

cp $snmp_etc_config /etc/snmp/snmpd.conf.etcbackup-$(date +"%Y_%m_%d_%I_%M_%p")

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
