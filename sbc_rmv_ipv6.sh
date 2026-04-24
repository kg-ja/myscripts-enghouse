#!/bin/bash



CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)



LOG_FILE=/tmp/sbc_$HOST_NAME-RMV-IPV6.txt




FILES=(
    "/etc/sysconfig/network-scripts/ifcfg-eth2"
    "/etc/sysconfig/network-scripts/ifcfg-eth3"
)


BASENAME=$(basename "$FILE")
BACKUP="/tmp/${BASENAME}.bak.$(date +%F-%H%M%S)"

# Lines to remove (exact match)
#PATTERN='^IPV6INIT *= *yes$|^IPV6_AUTOCONF *= *yes$|^IPV6_DEFROUTE *= *yes$|^IPV6_FAILURE_FATAL *= *no$|^IPV6_ADDR_GEN_MODE *= *stable-privacy$'
#PATTERN='^(IPV6INIT=yes|IPV6_AUTOCONF=yes|IPV6_DEFROUTE=yes|IPV6_FAILURE_FATAL=no|IPV6_ADDR_GEN_MODE=stable-privacy)$'

# Match any line starting with IPV6_
PATTERN='^IPV6'



hardware_platform()
{

echo "1.HARDWARE BASIC INFO" >> $LOG_FILE
echo >> "$LOG_FILE"
echo "=======================================================================================" >> "$LOG_FILE"
echo "Date: $CURRENT_TIMESTAMP" >> "$LOG_FILE"
echo "Hostname: $HOST_NAME" >> "$LOG_FILE"
echo "VM MGMT IP: $IP_VM" >> "$LOG_FILE"
echo "HP Mgmt IP: $IP_HW" >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "HW/VM -SBC-License-Platform-Details" >> $LOG_FILE
dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /opt/bnet/release_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/getVMVSystemInfo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

/opt/bnet/bin/bnetscs -ver >> $LOG_FILE

echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo >> "$LOG_FILE"

}

network_details()
{
echo >> "$LOG_FILE"
echo "9.NETWORK DETAILS" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*HA-HW*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-ha | grep "DEVICE\|NAME">> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-ha | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*MGMT-HW*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*HA-VM*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1| grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*MGMT-VM*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo >> $LOG_FILE
echo "*NMCLI DEVICE STATUS" >> $LOG_FILE
nmcli device status >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo >> $LOG_FILE
echo "*NMCLI CONNECTION" >> $LOG_FILE
nmcli connection >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

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
echo "*INTERFACE-CHECK-VM*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
echo "*ETH-0*" >> $LOG_FILE
cat ifcfg-eth0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
ethtool eth0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-1*" >> $LOG_FILE
cat ifcfg-eth1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
ethtool eth1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-2*" >> $LOG_FILE
cat ifcfg-eth2 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
ethtool eth2 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-3*" >> $LOG_FILE
cat ifcfg-eth3 >> $LOG_FILE
ethtool eth3 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE




echo "*INTERFACE-CHECK-COTS*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
echo "*MGMT*" >> $LOG_FILE
cat ifcfg-mgmt >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*HA*" >> $LOG_FILE
cat ifcfg-ha >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "*Session1*" >> $LOG_FILE
cat ifcfg-session1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "*Session2*" >> $LOG_FILE
cat ifcfg-session2 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "*NIC-0/3*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic0 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic3 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic3 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*NIC-1/2*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic1 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic2 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic2 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "*NIC-4/8*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic4 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic4 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic8 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic8 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "*ETH-5/9*" >> $LOG_FILE
cat ifcfg-nic5 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic9 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic9 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


}



network_ipv6_change()
{
for FILE in "${FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        echo "Checking $FILE"

        # Check if any matching lines exist
        if grep -Eq "$PATTERN" "$FILE"; then
            echo "Match found in $FILE → cleaning" | tee -a $LOG_FILE 

            # Backup before modification
              cp "$FILE" "$BACKUP"

            
            # Remove matching lines
			grep -E "$PATTERN" "$FILE" | tee -a $LOG_FILE 
            sed -i -E "/$PATTERN/d" "$FILE"

            echo "Cleaned $FILE" | tee -a $LOG_FILE 
        else
            echo "No matching IPv6 lines found in $FILE (skipping)" | tee -a $LOG_FILE 
        fi
    else
        echo "File not found: $FILE" | tee -a $LOG_FILE 
    fi
done


systemctl restart NetworkManager

sleep 4

echo "Done." | tee -a $LOG_FILE 

}



#MAIN

hardware_platform
network_details
network_ipv6_change

chmod 755 $LOG_FILE

exit 0