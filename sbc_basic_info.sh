#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')

LOG_FILE=/tmp/SBC_LOG_INFO-$HOST_NAME.log

clear
echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE

echo | tee -a "$LOG_FILE"
echo "Script running, please wait" 
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***-HARDWARE-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***CPU-INFO***" >> $LOG_FILE
lscpu >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -k >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***Full summary of available and used disk space usage of the file system***" >> $LOG_FILE
df -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***STORAGE-INFO***" >> $LOG_FILE
du -sh /archive/software/ >> $LOG_FILE
du -sh /cores >> $LOG_FILE
du -sh /var/crash/ >> $LOG_FILE
du -sh /eventdata/ >> $LOG_FILE
du -sh /archive/backup/config >> $LOG_FILE
du -sh /archive/SIP_capture >> $LOG_FILE
du -sh /archive/Trace_captures >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

du -h / --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --max-depth=1 | sort -rh | head -20 >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE

echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
top -b -o %MEM | head -n 16 >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CPU-PRINTOUT***" >> $LOG_FILE
top -b -o %CPU | head -n 16 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /proc/kbnet/cpu_usage >> $LOG_FILE
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




echo "***-SBC-PLATFORM-INFORMATION***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "*** HW/VM -SBC-License-Platform-Details***" >> $LOG_FILE

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
echo "=======================================================================================" >> $LOG_FILE


echo "***PLATFORM & PRODUCT***" >> $LOG_FILE
cat /opt/bnet/release_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo >> $LOG_FILE
/opt/BNSwMgr/swMgr DeploymentType  >> $LOG_FILE
echo >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***VM-SYSTEM-INFO***" >> $LOG_FILE
/opt/bnet/scripts/getVMVSystemInfo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***COT-SYSTEM-INFO***" >> $LOG_FILE
dmidecode -t system >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SOFTWARE-INFORMATION***" >> $LOG_FILE
cd /opt/bnet/bin/
./bnetscs -ver >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

cd /opt/bnet
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
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



cd /config/mibs/current/platform/host
echo "***HOST-MIB-INFO***" >> $LOG_FILE
ls -ltrh >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***SBC-DATA***" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CURRENT-MIB-DIRECTORY-PRINT***" >> $LOG_FILE
cd /config/mibs/current  
git branch -v >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
git log --pretty="%h, %ar : %s" -2 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE

echo "***LICENSE-TRIAL-INFO***" >> $LOG_FILE
cat /config/mibs/current/localmgmt/license/License_trial.xml >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***LICENSE-PROD-INFO***" >> $LOG_FILE
cat /config/mibs/current/localmgmt/license/License_prod.xml >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***LICENSE-NETOWRKWIDE-INFO***" >> $LOG_FILE
cat /config/mibs/current/localmgmt/networkwidelicense/NetworkWideLicensingCfg.xml >> $LOG_FILE
echo " =======================================================================================" >> $LOG_FILE



echo "***SYSTEM-UPGRADE-INFO***" >> $LOG_FILE
cd /var/adm/bnet
cat bnethistory.log >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***CORE-INFO***" >> $LOG_FILE
cd /cores
ls -ltrh >> $LOG_FILE
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


echo "=======================================================================================" >> $LOG_FILE
echo "***APP-PARAMs-Snippet***" >> $LOG_FILE

ls -ltr /config/mibs/current/appparams/AppParams.xml >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /config/mibs/current/appparams/AppParams.xml | grep PortReuseForReinvite >> $LOG_FILE
cat /config/mibs/current/appparams/AppParams.xml | grep PortReuseForHold >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /config/mibs/current/appparams/AppParams.xml | grep MaxAllowedCallDuration >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /config/mibs/current/appparams/AppParams.xml | grep RemoveSDPForUnrelRelConn18xWithSDP >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE




echo "***SKEW ADJUSTMENT CHECK***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /opt/bnet/bin/runcommonenv | grep SLEEP_TIMER_VALUE >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep SLEEP /archive/logger/*/bnett* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo " =======================================================================================" >> $LOG_FILE




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





echo "=======================================================================================" >> $LOG_FILE
echo "*-TRAFFIC-INTERFACE-STATS-COT*" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*NIC-4*" >> $LOG_FILE
ethtool -S nic4 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*NIC-5*" >> $LOG_FILE
ethtool -S nic5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE






echo "***GLASSFISH-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***GLASSFISH-SERVICE***" >> $LOG_FILE
systemctl status glassfish  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /opt/glassfish/glassfish/domains/domain1/logs
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***GLASSFISH-LOG-SNIPPET***" >> $LOG_FILE
tail -20 server.log >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cd /opt/glassfish/glassfish/domains/domain1/logs/server/tx
cat recoveryfile >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE


echo "***BNET-PIPEs***" >> $LOG_FILE
ls -ltrh /opt/bnet/bin/ | grep pipe >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE

echo "***SDR-FILE-INFO***" >> $LOG_FILE
cd /eventdata
ls -ltrh >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***SDRs-NOTSENT***" >> $LOG_FILE
cd /eventdata/notsent
ls -1 | wc -l >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***SDRs-SENT***" >> $LOG_FILE
cd /eventdata/sent
ls -1 | wc -l >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***SDRs-ANALYTICS***" >> $LOG_FILE
cd /eventdata/analytic
ls -1 | wc -l >> $LOG_FILE

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



echo "***BNET-SERVICES-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***GLASSFISH-SERVICE***" >> $LOG_FILE
systemctl status glassfish  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETSCS-SERVICE***" >> $LOG_FILE
systemctl status bnetscs  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETPM-SERVICE***" >> $LOG_FILE
systemctl status bnetpm  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETPPS-SERVICE***" >> $LOG_FILE
systemctl status bnetpps | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETVIEWMGR-SERVICE***" >> $LOG_FILE
systemctl status bnetgwmgr | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETTRM-SERVICE***" >> $LOG_FILE
systemctl status bnettrm | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETDAS-SERVICE***" >> $LOG_FILE
systemctl status bnetdas | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETGSM-SERVICE***" >> $LOG_FILE
systemctl status bnetgsm | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***BNETFMS-SERVICE***" >> $LOG_FILE
systemctl status bnetfms | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***POSTGRES***" >> $LOG_FILE
systemctl status postgres* | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***SBCRESTAPI***" >> $LOG_FILE
systemctl status sbcrestapi | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
ps -ef | grep runbnet >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***SYS-DROP***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /proc/kbnet/sys_drop >> $LOG_FILE
sleep 15
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

cat /proc/kbnet/sys_drop >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE



echo "***BNETSCS-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


grep -i "exceeded" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "sessions" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Un-Configured" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Transcoding" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE


echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Rejected" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE


echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


grep -i "GetNextIndex" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


grep -i "ACL" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE


echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Bad pointer\|RA_Alloc" /archive/logger/*/bnetscs_* | tail -10 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i BINDTODEVICE /archive/logger/*/bnetscs_* | tail -10 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Resource limit" /archive/logger/*/bnetscs_* | tail -10 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


grep -i "fqdn" /archive/logger/*/bnetscs_*  | grep -v "Info"  | tail -10  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE



grep -i "postgres" /archive/logger/*/bnetscs_* | grep -v "Info" | tail -10 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***BNETPPS-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i fail /archive/logger/*/bnetpps_* | tail -15 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i socket /archive/logger/*/bnetpps_* | grep -v "Info" | tail -15 >> $LOG_FILE

grep -i operation /archive/logger/*/bnetpps_* | grep -v "Info" | tail -5 >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE




echo "***BNETPM-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Configure HA" /archive/logger/*/bnetpm_* | grep -v "License" | tail -15 >> $LOG_FILE


echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i fail /archive/logger/*/bnetpm_* | grep -v "License" | tail -15 >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE



echo "***SBC-MESSAGES-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "Drop" /var/log/messages | tail -20 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "PRE_ROUTING" /var/log/messages | tail -10 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "ERROR" /var/log/messages | tail -10 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "avahi-daemon" /var/log/messages | tail -15 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE





echo "***SBC-bnsbc_license_SNIPPET***" >> $LOG_FILE
ls -ltrh bnsbc_license* >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***License_Detils***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*Sessions*" >> $LOG_FILE
cat /var/log/bnsbc_license* | grep BNNSL | tail -5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*EMS*" >> $LOG_FILE
cat /var/log/bnsbc_license* | grep BNEMS | tail -5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*IPSec-Tunnels*" >> $LOG_FILE
cat /var/log/bnsbc_license* | grep BNIPS | tail -5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*Transcoding-Gateway-Sessions*" >> $LOG_FILE
cat /var/log/bnsbc_license* | grep BNTSL | tail -5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "*Srtp-Sessions*" >> $LOG_FILE
cat /var/log/bnsbc_license* | grep BNSRS | tail -5 >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep -i "EmsConnectionLostGraceTime=0" /var/log/bnsbc_license* | tail -10 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
grep -i "EmsConnectionLostGraceTime" /var/log/bnsbc_license* | tail -25 >> $LOG_FILE



echo "=======================================================================================" >> $LOG_FILE




echo "***SBC-REST-API-LOG_SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

grep -i "url:" /archive/log/sbcrestapi/sbcrestapi.log | tail -3 >> $LOG_FILE

grep -i "operationId:" /archive/log/sbcrestapi/sbcrestapi.log | tail -3 >> $LOG_FILE

grep -i "Connection timed out" /archive/log/sbcrestapi/sbcrestapi.log | tail -3 >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE



echo "***SNMP-SETUP-SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep com2sec >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep group >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "CURRENT SNMPv3 USERS" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------">> $LOG_FILE
echo "rouser\| rwuser count" >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep "rouser\| rwuser" | wc -l >> $LOG_FILE
echo "---------------------------------------------------------------------------------------">> $LOG_FILE
echo " Specific Users: " >> $LOG_FILE
cat /etc/snmp/snmpd.conf | grep "rouser\| rwuser" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo | tee -a "$LOG_FILE"
echo "usmUser  count" >> $LOG_FILE
cat /var/lib/net-snmp/snmpd.conf | grep -i usmUser | wc -l >> $LOG_FILE
echo "---------------------------------------------------------------------------------------">> $LOG_FILE
cat /var/lib/net-snmp/snmpd.conf | grep -i usmUser | tee -a $LOG_FILE
echo "---------------------------------------------------------------------------------------">> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***SNMP-SERVICES-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***SNMP-SERVICE***" >> $LOG_FILE
systemctl status snmpd  | grep "Active\b" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
systemctl status snmpd >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE
echo "***********ANALYTICS-SETUP-SNIPPET************" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***HOST-CONFIG***" >> $LOG_FILE
cat /opt/analytic/dataforwarder/config/forwarder.yml | grep hosts >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /opt/analytic/dataforwarder/config/forwarder.yml | head -5 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***DATA-FWD-LOG***" >> $LOG_FILE
tail -15 /archive/analytic/dataforwarder.log.0 >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***DATA-FWD-LOG-SDR***" >> $LOG_FILE
tail -15 /archive/analytic/dataforwarder.log.0  | grep "sdr" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SBC-USERS-INFO***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***Current-Logged-IN***" >> $LOG_FILE
who >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/passwd >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


echo "***SBC-SSH-CONFIG-SNIPPET***" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /etc/ssh/sshd_config | grep -i "PermitRootLogin\|PasswordAuthentication\|PubkeyAuthentication\|AuthorizedKeysFile"  >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE


clear
echo | tee -a "$LOG_FILE"
 

chmod 755 $LOG_FILE

mv $LOG_FILE /tmp/SBC_LOG_INFO-$HOST_NAME-$theSerial-$(date +"%Y_%m_%d_%I_%M_%p").log

echo "This script has completed, please check /tmp folder for log to send to support" 

exit 0;
