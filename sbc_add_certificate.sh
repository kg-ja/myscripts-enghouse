#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
theIPaddressVM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
theIPaddressHW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)

TMP_DIR="/tmp"
CERT_DIR="/config/mibs/current/security/certificate"
LOG_FILE="/tmp/add_sbc_certificate_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="/tmp/certificate_backup_$(date +%Y%m%d_%H%M%S)"



hardware_platform()
{

echo "=======================================================================================" >> $LOG_FILE
echo "SBC HARDWARE BASIC INFO" >> $LOG_FILE
echo >> "$LOG_FILE"
echo "=======================================================================================" >> $LOG_FILE
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
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo "***CPU-INFO***" >> $LOG_FILE
lscpu | grep -E '^(Architecture|CPU\(s\)|Vendor ID|Model name|Stepping|CPU MHz|BogoMIPS|Hypervisor vendor|Virtualization type):' >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "***MEMORY-PRINTOUT***" >> $LOG_FILE
echo | tee -a "$LOG_FILE"
dmidecode -t memory | grep -i 'Size:' | grep -v 'No Module Installed' | grep -i 'MB'  | awk '{sum += $2} END {print sum, "MB"}' >> $LOG_FILE
echo | tee -a "$LOG_FILE"
dmidecode -t memory | grep -i 'Size:' | grep -v 'No Module Installed' | grep -i 'GB'  | awk '{sum += $2} END {print sum, "GB"}' >> $LOG_FILE
echo | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -h >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
free -k >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
cat /opt/bnet/release_info >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/getVMVSystemInfo >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
/opt/bnet/scripts/swMgr Summary >> $LOG_FILE
echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

/opt/bnet/bin/bnetscs -ver >> $LOG_FILE


echo "=======================================================================================" >> $LOG_FILE

}

clear
echo "=======================================================================================" > $LOG_FILE
echo "***$CURRENT_TIMESTAMP-$HOST_NAME-$theIPaddressVM-$theIPaddressHW***" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

SERVICE_STOPPED=0

exec > >(tee -a "$LOGFILE") 2>&1


#-------------------------------------------------------
# Cleanup / Emergency restart
#-------------------------------------------------------
cleanup()
{
    if [[ $SERVICE_STOPPED -eq 1 ]]; then
        echo "Restarting bnetpps due to script exit..."
        systemctl start bnetpps
    fi
}

trap cleanup EXIT


#-------------------------------------------------------
# Check root
#-------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi


echo "=============================================="
echo "SBC Certificate Installation"
echo "Started: $(date)"
echo "Log: $LOGFILE"
echo "=============================================="


#-------------------------------------------------------
# Verify certificate directory
#-------------------------------------------------------
if [[ ! -d "$CERT_DIR" ]]; then
    echo "ERROR: Certificate directory does not exist:"
    echo "$CERT_DIR"
    exit 1
fi


#-------------------------------------------------------
# Check Git repository is clean
#-------------------------------------------------------
cd "$CERT_DIR" || exit 1

if [[ -n "$(git status --porcelain)" ]]; then
    echo
    echo "ERROR: Git working directory contains uncommitted changes."
    echo
    git status
    exit 1
fi


#-------------------------------------------------------
# Find XML files in /tmp
#-------------------------------------------------------
mapfile -t XML_FILES < <(find "$TMP_DIR" -maxdepth 1 -type f \
-name "SbcCertificateEntry_*.xml" | sort -V)


if [[ ${#XML_FILES[@]} -eq 0 ]]; then
    echo "No SbcCertificateEntry XML files found in $TMP_DIR"
    exit 1
fi


echo
echo "Available XML files:"
echo


for i in "${!XML_FILES[@]}"; do
    printf "%2d) %s\n" $((i+1)) "$(basename "${XML_FILES[$i]}")"
done


echo
read -p "Select file to install: " CHOICE


if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || \
((CHOICE < 1 || CHOICE > ${#XML_FILES[@]})); then

    echo "Invalid selection."
    exit 1
fi


SELECTED_FILE="${XML_FILES[$((CHOICE-1))]}"
BASENAME=$(basename "$SELECTED_FILE")


echo
echo "Selected file:"
echo "$BASENAME"



#-------------------------------------------------------
# Backup certificate directory
#-------------------------------------------------------
echo
echo "Creating certificate backup..."

mkdir -p "$BACKUP_DIR"

cp -a "$CERT_DIR"/. "$BACKUP_DIR"/


echo "Backup created:"
echo "$BACKUP_DIR"



#-------------------------------------------------------
# Check duplicate filename
#-------------------------------------------------------

if [[ -f "$CERT_DIR/$BASENAME" ]]; then


    echo
    echo "ERROR: File exists in location already:"
    echo "$CERT_DIR/$BASENAME"

    echo
    echo "Current certificate files:"
    ls -1v "$CERT_DIR"/SbcCertificateEntry_*.xml


    echo
    echo "Determining next certificate number..."


    LAST_FILE=$(ls -1v "$CERT_DIR"/SbcCertificateEntry_*.xml | tail -1)


    LAST_NUM=$(basename "$LAST_FILE" | \
    sed -E 's/SbcCertificateEntry_([0-9]+)\.xml/\1/')


    NEXT_NUM=$((LAST_NUM + 1))


    NEW_NAME="SbcCertificateEntry_${NEXT_NUM}.xml"


    TMP_NEW_FILE="$TMP_DIR/$NEW_NAME"


    echo
    echo "Renaming:"
    echo "FROM: $BASENAME"
    echo "TO  : $NEW_NAME"


    cp "$SELECTED_FILE" "$TMP_NEW_FILE"



    #-----------------------------------------------
    # Validate Id tag
    #-----------------------------------------------

    ID_COUNT=$(grep -o "<Id>[0-9]\+</Id>" "$TMP_NEW_FILE" | wc -l)


    if [[ "$ID_COUNT" -ne 1 ]]; then

        echo
        echo "ERROR: Expected exactly one <Id> tag."
        echo "Found: $ID_COUNT"
        exit 1

    fi



    #-----------------------------------------------
    # Update XML Id
    #-----------------------------------------------

    sed -i -E \
    "s|<Id>[0-9]+</Id>|<Id>${NEXT_NUM}</Id>|" \
    "$TMP_NEW_FILE"


else


    echo
    echo "File does not exist in certificate directory."
    echo "Keeping original filename and XML Id."


    NEW_NAME="$BASENAME"

    TMP_NEW_FILE="$TMP_DIR/$NEW_NAME"



fi

hardware_platform

#-------------------------------------------------------
# Confirm installation
#-------------------------------------------------------

echo
echo "Ready to install:"
echo "File : $NEW_NAME"


read -p "Copy file into certificate directory? (yes/no): " ANSWER


if [[ ! "$ANSWER" =~ ^[Yy](es)?$ ]]; then
    echo "Cancelled."
    exit 0
fi



cp "$TMP_NEW_FILE" "$CERT_DIR/$NEW_NAME"


if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed copying file."
    exit 1
fi


echo
echo "File copied successfully."



#-------------------------------------------------------
# Stop service
#-------------------------------------------------------

echo
echo "Stopping bnetpps..."

systemctl stop bnetpps


if [[ $? -ne 0 ]]; then
    echo "Failed stopping bnetpps."
    exit 1
fi


SERVICE_STOPPED=1



#-------------------------------------------------------
# Parse Provisioning
#-------------------------------------------------------

cd $CERT_DIR

echo
echo "Running ParseProvisioning..."

/opt/bnet/bin/ParseProvisioning -r


if [[ $? -ne 0 ]]; then

    echo "ERROR: ParseProvisioning failed."

    exit 1

fi



#-------------------------------------------------------
# Git commit
#-------------------------------------------------------

echo
echo "Running git commit..."


git add .


git commit -m "Added new files and updated existing files"


if [[ $? -ne 0 ]]; then

    echo "ERROR: Git commit failed."

    exit 1

fi



#-------------------------------------------------------
# Start service
#-------------------------------------------------------

echo
echo "Starting bnetpps..."

systemctl start bnetpps


SERVICE_STOPPED=0

chmod 755 $LOG_FILE

echo
echo "=============================================="
echo "Completed successfully"
echo "Completed: $(date)"
echo "Log file: $LOG_FILE"
echo "=============================================="





exit 0;