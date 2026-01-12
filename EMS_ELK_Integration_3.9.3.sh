#!/bin/bash

###############################################################################
# EMS_ELK_Integration_3.9.3.sh
#
# Purpose:
#   Validate Kibana service, recover if failed, then enforce basePath config
#   required for EMS integration.
###############################################################################

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)

DATE=$(date '+%Y-%m-%d %H:%M:%S')

theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
iface=$(ip -o link show | awk -F': ' '$1==2 {print $2}')
theIPaddress=$(ip addr show $iface | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


LOG_FILE="/tmp/ems_elk_integration_3.9.3.log"
KIBANA_SERVICE="kibana"
KIBANA_CONF="/etc/kibana/kibana.yml"
BASE_PATH='server.basePath: "/analytic"'
REWRITE_PATH='server.rewriteBasePath: true'

exec > >(tee -a "$LOG_FILE") 2>&1



Check_EMS_Integration()

{

###############################################################################
# Check each line individually
###############################################################################

FOUND_BASEPATH=false
FOUND_REWRITE=false

grep -Fxq "$BASE_PATH" "$KIBANA_CONF" && FOUND_BASEPATH=true
grep -Fxq "$REWRITE_PATH" "$KIBANA_CONF" && FOUND_REWRITE=true

if [[ "$FOUND_BASEPATH" != true ]]; then
    echo "ERROR: Missing line: $BASE_PATH" 
fi

if [[ "$FOUND_REWRITE" != true ]]; then
    echo "ERROR: Missing line: $REWRITE_PATH" 
fi

if [[ "$FOUND_BASEPATH" = true ]]; then
    echo "$BASE_PATH exists" 
fi

if [[ "$FOUND_REWRITE" = true ]]; then
    echo "$REWRITE_PATH exists" 
fi



if [[ "$FOUND_BASEPATH" = true && "$FOUND_REWRITE" = true ]]; then
    echo "Configuration is already in place."
	exit 1;
    
fi


if [[ "$FOUND_BASEPATH" != true && "$FOUND_REWRITE" != true ]]; then
    echo "Configuration is not in place."
fi
	
}


Add_EMS_Integration ()

{

kibana_verify

Check_EMS_Integration

basic_data

kibana_service_state

kibana_ems_enforce
}


Rmv_EMS_Integration ()

{

kibana_verify

basic_data

kibana_service_state

kibana_rmv_lines
}




basic_data()

{
echo "==========================SIPp-BASIC-DATA===================================" > $LOG_FILE

clear


echo "=================================================="
echo "EMS ELK Integration 3.9.3 - $(date)"
echo "=================================================="


echo "Current DATE: $DATE]" >> $LOG_FILE

echo "The Interface name of this system is $iface " >> $LOG_FILE

echo "The IP address of this system is $theIPaddress " >> $LOG_FILE

echo "The Hostname of this system is $HOST_NAME " >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***CPU-INFO***" >> $LOG_FILE
lscpu >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
free -h >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "***OS-RELEASE***" >> $LOG_FILE
cat /etc/os-release >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

}



kibana_verify() {

###############################################################################
# 1. Verify Kibana service exists
###############################################################################

echo "Validating Kibana service presence..."

if ! systemctl list-unit-files | grep -q "^${KIBANA_SERVICE}.service"; then
    echo "ERROR: Kibana service is not installed on this server."
    exit 1
fi

###############################################################################
# 2. Validate kibana.yml
###############################################################################

echo "Validating Kibana configuration file..."

if [[ ! -f "$KIBANA_CONF" ]]; then
    echo "ERROR: $KIBANA_CONF does not exist. Cannot proceed."
    exit 2
fi


}


kibana_service_state()
{

###############################################################################
# 3. Evaluate Kibana service state
###############################################################################

echo "Checking Kibana service status..."
STATUS_OUTPUT=$(systemctl status kibana 2>&1)

if echo "$STATUS_OUTPUT" | grep -q "Active: failed"; then
    echo "Kibana service is in FAILED state. Initiating recovery."

    echo "Locating Kibana processes..."
    PIDS=$(pgrep -f "/usr/share/kibana" | xargs)

    if [[ -n "$PIDS" ]]; then
        echo "Kibana PIDs found: $PIDS"
        echo "Force-terminating Kibana processes..."
        pkill -9 -f "/usr/share/kibana"
        sleep 5
    else
        echo "No running Kibana processes detected."
    fi

    echo "Restarting Kibana service..."
    systemctl restart kibana
    sleep 10

    if systemctl is-active --quiet kibana; then
        echo "Kibana service recovered successfully."
    else
        echo "ERROR: Kibana failed to recover after restart."
        systemctl status kibana
        exit 2
    fi
else
    echo "Kibana service is not in failed state."
    systemctl status kibana | grep Active
fi

}

kibana_rmv_lines()

{
###############################################################################
# Check each line individually
###############################################################################

FOUND_BASEPATH=false
FOUND_REWRITE=false

grep -Fxq "$BASE_PATH" "$KIBANA_CONF" && FOUND_BASEPATH=true
grep -Fxq "$REWRITE_PATH" "$KIBANA_CONF" && FOUND_REWRITE=true

if [[ "$FOUND_BASEPATH" != true ]]; then
    echo "ERROR: Missing line: $BASE_PATH" 
fi

if [[ "$FOUND_REWRITE" != true ]]; then
    echo "ERROR: Missing line: $REWRITE_PATH" 
fi

if [[ "$FOUND_BASEPATH" != true || "$FOUND_REWRITE" != true ]]; then
    echo "Configuration is not in the expected state. No changes made." 
    exit 2
fi

###############################################################################
# Both lines are present — remove them
###############################################################################

echo "Both configuration lines detected."
echo "Removing EMS basePath configuration..."

sed -i "\|^${BASE_PATH}$|d" "$KIBANA_CONF"
sed -i "\|^${REWRITE_PATH}$|d" "$KIBANA_CONF"

echo "The following entries were removed:"
echo "  - $BASE_PATH"
echo "  - $REWRITE_PATH"


###############################################################################
# 5. Restart Kibana to apply config
###############################################################################

echo "Restarting Kibana to apply new configuration..."
systemctl restart kibana
sleep 10

if systemctl is-active --quiet kibana; then
    echo "Kibana restarted successfully with EMS configuration."
else
    echo "ERROR: Kibana failed to start after configuration update."
    systemctl status kibana
    exit 4
fi

echo "EMS ELK Integration configuration successfully removed."

}


kibana_ems_enforce() {

###############################################################################
# 4. Enforce EMS basePath configuration
###############################################################################

echo "Applying EMS basePath configuration..."

if ! grep -q "^server.basePath:" "$KIBANA_CONF"; then
    echo "$BASE_PATH" >> "$KIBANA_CONF"
    echo "Added: $BASE_PATH"
else
    echo "server.basePath already present."
fi

if ! grep -q "^server.rewriteBasePath:" "$KIBANA_CONF"; then
    echo "$REWRITE_PATH" >> "$KIBANA_CONF"
    echo "Added: $REWRITE_PATH"
else
    echo "server.rewriteBasePath already present."
fi

###############################################################################
# 5. Restart Kibana to apply config
###############################################################################

echo "Restarting Kibana to apply new configuration..."
systemctl restart kibana
sleep 10

if systemctl is-active --quiet kibana; then
    echo "Kibana restarted successfully with EMS configuration."
else
    echo "ERROR: Kibana failed to start after configuration update."
    systemctl status kibana
    exit 4
fi

echo "EMS ELK Integration completed successfully."

}



# MAIN



echo " Welcome to Analytics EMS Integration "
    echo " Please choose from options below"
    echo ""
	echo "1. Check if configuration is already in place for Analytics to be accessed via SBC_EMS"
    echo "2. Configure Analytics to be accessed via SBC_EMS"
    echo "3. Remove Configuration from Analytics for SBC_EMS Integartion "    
    echo "4. Exit"
    echo ""

    read -rp "Enter your choice [1-4]: " choice

    case $choice in
        1) Check_EMS_Integration ;;
        2) Add_EMS_Integration;;   
        3) Rmv_EMS_Integration ;;		
        4) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please choose a number between 1 and 4." ;;
    esac




chmod 755 $LOG_FILE



exit 0;
