#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)




#
# SBC Software setup Script
# looks for software files in/tmp folder and move to correct location and change permissions
#
# Output:
#   - modified software file in correct location for upgrade
#   
#

set -euo pipefail

#########################################
# Configuration
#########################################

TMP_DIR="/tmp"
DEST_DIR="/archive/software"
LOG_FILE="${TMP_DIR}/${HOST_NAME}-${SERIAL}-${IP_VM}-${IP_HW}-SOFTWARESETUP.log"

touch "$LOG_FILE"


if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

#########################################
# Display available software files
#########################################

clear

mapfile -t BORDERNET_FILES < <(
    find "$TMP_DIR" -maxdepth 1 -type f -name "bordernet-*.tar.gz" | sort
)

COUNT=${#BORDERNET_FILES[@]}

if [[ $COUNT -eq 0 ]]; then
    echo "No bordernet package (*.tar.gz) found in $TMP_DIR"
    exit 1
fi

echo
echo "Current software of this System:" | tee -a "$LOG_FILE"
echo
echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
/opt/bnet/scripts/swMgr Summary | tee -a "$LOG_FILE"
echo
echo "---------------------------------------------------------------------------------------" | tee -a "$LOG_FILE"
/opt/bnet/bin/bnetscs -ver | tee -a "$LOG_FILE"
echo

echo "Available Bordernet packages:"
echo "-----------------------------"

echo " 0) Exit"
for i in "${!BORDERNET_FILES[@]}"; do
    printf "%2d) %s\n" $((i+1)) "$(basename "${BORDERNET_FILES[$i]}")"
done




echo
while true; do
    read -rp "Select package to prep install [0-$COUNT]: " CHOICE
	
	 # Exit option
    if [[ "$CHOICE" == "0" ]]; then
        echo "Exiting."
        exit 0
    fi
     
	# Valid selection
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= COUNT )); then
        break
    fi

    echo "Invalid selection."
done

echo

echo "file verification in process....."

echo
SELECTED_FILE="${BORDERNET_FILES[$((CHOICE-1))]}"
FILENAME=$(basename "$SELECTED_FILE")
DEST_FILE="$DEST_DIR/$FILENAME"
EXTRACT_DIR=$(tar -tzf "$SELECTED_FILE" | sed -n '1s#/.*##p')

echo

#########################################
# Verify destination directory
#########################################

# Ensure destination directory exists
if [[ ! -d "$DEST_DIR" ]]; then
    echo "ERROR: Destination directory does not exist:"
    echo "       $DEST_DIR"
    exit 1
fi

# Check if package already exists
if [[ -e "$DEST_FILE" ]]; then
    echo "ERROR: Package already exists in $DEST_DIR"
    echo "       $FILENAME"
    exit 1
fi

if [[ -d "$DEST_DIR/$EXTRACT_DIR" ]]; then
    echo "ERROR: Software package is already extracted:"
    echo "      $DEST_DIR/$EXTRACT_DIR"
    exit 1
fi

#########################################
# Check existing software directory
#########################################

# Find existing bordernet-* directories
mapfile -t EXISTING_DIRS < <(
    find "$DEST_DIR" -mindepth 1 -maxdepth 1 -type d -name "bordernet-*"
)

DIR_COUNT=${#EXISTING_DIRS[@]}

if (( DIR_COUNT > 0 )); then
    echo
    echo "WARNING: Destination already contains the following software directory:"
    printf "  %s\n" "${EXISTING_DIRS[@]}"
    echo
    read -rp "Overwrite existing software? (yes/no): " ANSWER

    case "${ANSWER,,}" in
        yes|y)
            echo
            echo "Removing existing software directory..."

            for DIR in "${EXISTING_DIRS[@]}"; do
                echo "  Removing $(basename "$DIR")"
                rm -rf "$DIR"
            done

            echo "Existing software removed."
            echo
            ;;
        no|n)
            echo "Operation cancelled."
            exit 0
            ;;
        *)
            echo "Invalid response. Please answer yes or no."
            exit 1
            ;;
    esac
fi

echo


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

echo >> "$LOG_FILE"
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE

echo >> "$LOG_FILE"
echo "=======================================================================================" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***STORAGE-INFO***" >> $LOG_FILE
du -sh /archive/software/ >> $LOG_FILE

echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Available SOFTWARE Files ($COUNT)" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo
echo "Selected for analysis:" >> $LOG_FILE
echo "  $FILENAME" >> $LOG_FILE
echo
echo "=======================================================================================" >> $LOG_FILE

}


#########################################
# Verify files
#########################################

if [[ ! -f "$SELECTED_FILE" ]]; then
    echo "ERROR: Software package not found:"
    echo "       $SELECTED_FILE"
    exit 1
fi

#########################################
# CP and EXTRACT SOFTWARE (delete .gz)
#########################################

echo
echo "Moving $FILENAME to $DEST_DIR..."
cp "$SELECTED_FILE" "$DEST_FILE" || {
    echo "ERROR: Failed to move file."
    exit 1
}

echo "Setting permissions..."
chmod 755 "$DEST_FILE" || {
    echo "ERROR: chmod failed."
    exit 1
}

echo "Extracting archive..."
tar -xzf "$DEST_FILE" -C "$DEST_DIR" || {
    echo "ERROR: Extraction failed."
    exit 1
}

echo "Removing archive..."
rm -f "$DEST_FILE"



#########################################
# SBC Details
#########################################
hardware_platform

#########################################
# Summary
#########################################

echo
echo "==============================================" | tee -a $LOG_FILE

chmod 755 $LOG_FILE

echo "Package successfully extracted to $DEST_DIR"
echo
echo "Available Directories in Software folder:"
ls -ltrh "$DEST_DIR"
echo
echo "==============================================" | tee -a $LOG_FILE
echo
echo "Software version Summary:"
echo
/opt/bnet/scripts/swMgr Summary | tee -a "$LOG_FILE"
echo
echo
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Log File  : $LOG_FILE" | tee -a $LOG_FILE
echo "==============================================" | tee -a $LOG_FILE

exit 0;