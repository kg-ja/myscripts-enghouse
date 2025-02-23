#!/bin/bash

CURRENT_TIMESTAMP=`date`
HOST_NAME=`hostname`
EMSIP=$(cat /var/adm/ems/ems_ip)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
EMSROLE=$(cat /var/adm/ems/server_role)

LOG_FILE=/tmp/EMS_LOG_INFO-$HOST_NAME.log


echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***-HARDWARE-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***CPU-INFO***" >> $LOG_FILE
lscpu >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***-EMS-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "*** HW/VM -EMS-License-Platform-Details***" >> $LOG_FILE

dmidecode -t system | grep Manufacturer >> $LOG_FILE
dmidecode -t system | grep Product >> $LOG_FILE
dmidecode -t system | grep Serial >> $LOG_FILE
dmidecode -t system | grep UUID >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "*NETWORK INTERFACE PRINT*" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
ls -ltrh >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*MGMT-HW*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*IPADDR/NETMASK/GATEWAY-mgmt*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "IPADDR" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "NETMASK" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-mgmt | grep "GATEWAY" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno1 | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno1 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*IPADDR/NETMASK/GATEWAY-eno1*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno1 | grep "IPADDR" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno1 | grep "NETMASK" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno1 | grep "GATEWAY" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno2 | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno2 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*IPADDR/NETMASK/GATEWAY-eno2*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno2 | grep "IPADDR" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno2 | grep "NETMASK" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eno2 | grep "GATEWAY" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*MGMT0-VM*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*IPADDR/NETMASK/GATEWAY-eth0 *" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "IPADDR" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "NETMASK" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep "GATEWAY" >> $LOG_FILE
echo "========================================================================="

echo "*MGMT1-VM*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1| grep "DEVICE\|NAME" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep "HWADDR\|MACADDR" >> $LOG_FILE
echo "*IPADDR/NETMASK/GATEWAY-eth1*" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep "IPADDR" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep "NETMASK" >> $LOG_FILE
cat /etc/sysconfig/network-scripts/ifcfg-eth1 | grep "GATEWAY" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE


echo "***PLATFORM & PRODUCT***" >> $LOG_FILE
cat /opt/ems/release_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***COT-SYSTEM-INFO***" >> $LOG_FILE
dmidecode -t system >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SOFTWARE-INFORMATION***" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /opt/ems
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /data/software
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/os-release >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/redhat-release >>  $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
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
echo "***SYSTEM-UPTIME-INFO***" >> $LOG_FILE
uptime >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***Time Of Last System Boot***" >> $LOG_FILE
who -b >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***System Reboots***" >> $LOG_FILE
last reboot >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SYSTEM-UPGRADE-INFO***" >> $LOG_FILE
cd /var/adm/ems
cat emshistory.log >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***KERNEL-CORE-INFO***" >> $LOG_FILE
cd /var/crash
ls -ltrh >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***HOST-INFO***" >> $LOG_FILE
cd /etc
cat hostname >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat hosts >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***DNS-INFO***" >> $LOG_FILE
cd /etc
cat resolv.conf >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***CRONTAB-ENTRIES***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
crontab -l >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***STORAGE-INFO***" >> $LOG_FILE

du -sh /var/ >> $LOG_FILE
du -sh /var/crash/ >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE

echo "***Full summary of available and used disk space usage of the file system***" >> $LOG_FILE
df -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
top -b -o %MEM | head -n 16 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CPU-PRINTOUT***" >> $LOG_FILE
top -b -o %CPU | head -n 16 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
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


echo "=======================================================================================" >> $LOG_FILE
echo "*-TRAFFIC-INTERFACE-STATS-VM*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-2*" >> $LOG_FILE
ethtool -S eth2 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*ETH-3*" >> $LOG_FILE
ethtool -S eth3 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE






echo "*INTERFACE-CHECK-COTS*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /etc/sysconfig/network-scripts
echo "*MGMT*" >> $LOG_FILE
cat ifcfg-mgmt >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "*NIC-0*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic0 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*NIC-1*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat ifcfg-nic1 | grep "ADDR\|DEVICE" >> $LOG_FILE
ethtool nic1 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE



echo "=======================================================================================" >> $LOG_FILE

echo "***TIME-SYNC***" >> $LOG_FILE
cat /etc/chrony.conf >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***TIME-SOURCES-TRACKING***" >> $LOG_FILE
chronyc sources >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
chronyc tracking >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
chronyc ntpdata >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "***EMS-SERVICES-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***EMS***" >> $LOG_FILE
systemctl status ems  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***couchbase-server***" >> $LOG_FILE
systemctl status couchbase-server  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE



echo "***EMS-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

cat /archive/log/ems/ems.log | grep -i tomcat >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "keepAlive" /archive/log/ems/ems.log | tail -10  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Keep Alive" /archive/log/ems/ems.log | tail -15  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "KA counter" /archive/log/ems/ems.log | tail -10  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Corrupted" /archive/log/ems/ems.log  | tail -10  >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE


echo "***SBC-MESSAGES-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Drop" /var/log/messages | tail -10 >> $LOG_FILE

grep -i "ERROR" /var/log/messages | tail -5 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE




echo "***EMS-REST-API-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

tail -20 /archive/log/emsrestapi/emsrestapi.log >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE



echo "***SNMP-SETUP-SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep com2sec >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep group >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep rouser >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***EMS-USERS-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***Current-Logged-IN***" >> $LOG_FILE
who >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/passwd >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***EMS-SSH-CONFIG-SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/ssh/sshd_config | grep -i "PermitRootLogin\|PasswordAuthentication\|PubkeyAuthentication\|AuthorizedKeysFile"  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE




chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/EMS_LOG_INFO-$HOST_NAME-$EMSROLE-$EMSIP-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;



