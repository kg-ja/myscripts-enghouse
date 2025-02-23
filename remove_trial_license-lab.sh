#!/bin/bash

LOG_FILE=/tmp/remove_trial_license.log

LICENSE_DIR=/config/mibs/current/localmgmt/license/
TRIAL_LICENSE_XML=License_trial.xml
TRIAL_LICENSE_BIN=License_trial.bin

HOST_NAME=`hostname`

CURRENT_TIMESTAMP=`date`

COMMIT_CHANGES=0

echo "***$CURRENT_TIMESTAMP - START OF LOG***" > $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Hostname of this server is $HOST_NAME" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***PLATFORM***" >> $LOG_FILE
cat /opt/bnet/release_info >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "***VM-SYSTEM-INFO***" >> $LOG_FILE
/opt/bnet/scripts/getVMVSystemInfo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***SOFTWARE***" >> $LOG_FILE
cd /opt/bnet/bin/
./bnetscs -ver >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/redhat-release >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE




cd $LICENSE_DIR


if [ ! -f $TRIAL_LICENSE_XML ] && [ ! -f $TRIAL_LICENSE_BIN ]; then
        echo "$TRIAL_LICENSE_XML and $TRIAL_LICENSE_BIN doesn't exist...no action taken" >> $LOG_FILE
        mv $LOG_FILE /tmp/remove_trial_license-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log
exit 0;
fi


echo "$CURRENT_TIMESTAMP - Removing trial license..." >> $LOG_FILE


echo "Stopping bnetpps..." >> $LOG_FILE
service bnetpps stop

if [ ! -f $TRIAL_LICENSE_XML ]; then
        echo "$TRIAL_LICENSE_XML doesn't exist..." >> $LOG_FILE
else
        echo "Removing $TRIAL_LICENSE_XML from git..." >> $LOG_FILE
        git rm -f $TRIAL_LICENSE_XML
        COMMIT_CHANGES=1
fi

if [ ! -f $TRIAL_LICENSE_BIN ]; then
        echo "$TRIAL_LICENSE_BIN doesn't exist..." >> $LOG_FILE
else
        echo "Removing $TRIAL_LICENSE_BIN from git..." >> $LOG_FILE
        git rm -f $TRIAL_LICENSE_BIN
        COMMIT_CHANGES=1
fi

if [[ $COMMIT_CHANGES == 1 ]]; then
        echo "Commiting changes in git..." >> $LOG_FILE
        git commit -m "Removed trial license"
fi


echo "Starting bnetpps..." >> $LOG_FILE
service bnetpps start


echo "trial license removed successfully..." >> $LOG_FILE

chmod 755 $LOG_FILE


mv $LOG_FILE /tmp/remove_trial_license-$HOST_NAME-$(date +"%Y_%m_%d_%I_%M_%p").log

exit 0;
