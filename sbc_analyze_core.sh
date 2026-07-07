#!/bin/bash

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
SERIAL=$(dmidecode -t system | awk '/Serial/ {print $3}')
IP_VM=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip -4 addr show mgmt 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)




#!/bin/bash
#
# SBC Core Analysis Script
# Extracts a compressed core file and runs GDB analysis.
#
# Output:
#   - Extracted core file (original .gz preserved)
#   - Timestamped GDB analysis log in /cores
#

set -euo pipefail

#########################################
# Configuration
#########################################

CORE_DIR="/cores"
TMP_DIR="/tmp"
default_BIN="/opt/bnet/bin/bnetscs"
default_BIN2="/opt/bnet/bin/bnetpm"
default_BIN3="/opt/bnet/bin/bnetftr"
default_BIN4="/opt/bnet/bin/bnettgw"
default_BIN5="/opt/bnet/bin/bnettrm"
default_BIN6="/opt/bnet/bin/bnetfms"

#########################################
# Display available core files
#########################################

clear

mapfile -t CORE_FILES < <(find "$CORE_DIR" -maxdepth 1 -type f -name "*.gz" | sort)

COUNT=${#CORE_FILES[@]}

if [[ $COUNT -eq 0 ]]; then
    echo "No compressed core files (*.gz) found in $CORE_DIR"
    exit 1
fi

echo
echo "===================================================="
echo "Available Core Files ($COUNT)"
echo "===================================================="


echo " 0) Exit"
for i in "${!CORE_FILES[@]}"; do
    printf "%2d) %s\n" $((i+1)) "$(basename "${CORE_FILES[$i]}")"
done



while true; do
    read -rp "Select a core file (0-$COUNT): " CHOICE

    # Exit option
    if [[ "$CHOICE" == "0" ]]; then
        echo "Exiting."
        exit 0
    fi

    # Valid selection
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && ((CHOICE>=1 && CHOICE<=COUNT)); then
        break
    fi

    echo "Invalid selection. Please choose a number between 0 and $COUNT."
done

echo

echo "Core Analysis Process ( no choice will use default):"
echo "  1) bnetscs (default)"
echo "  2) bnetpm"
echo "  3) bnetftr"
echo "  4) bnettgw"
echo "  5) bnettrm"
echo "  6) bnetfms"
echo

read -rp "Enter your choice [1-5] (Default: 1): " BIN_CHOICE

# Default to option 1 if no input
 BIN_CHOICE=${BIN_CHOICE:-1}

case "$BIN_CHOICE" in
    1)
        BIN="$default_BIN"
        ;;
    2)
        BIN="$default_BIN2"
        ;;
    3)
        BIN="$default_BIN3"
        ;;
    4)
        BIN="$default_BIN4"
        ;;
    5)
        BIN="$default_BIN5"
        ;;
    6)
        BIN="$default_BIN6"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

echo
echo "Selected binary: $BIN" 

echo

CORE_GZ_PATH="${CORE_FILES[$((CHOICE-1))]}"
CORE_GZ=$(basename "$CORE_GZ_PATH")
CORE="${CORE_GZ%.gz}"
CORE_PATH="${CORE_DIR}/${CORE}"

LOG_FILE="${TMP_DIR}/${HOST_NAME}-${SERIAL}-${IP_VM}-${IP_HW}-${CORE}-gdb_analysis.log"

echo
echo "Selected:"
echo "  $CORE_GZ"
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
lscpu >> $LOG_FILE

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
echo >> $LOG_FILE
echo "***CORE-INFO***" >> $LOG_FILE
cd /cores
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***KERNEL-CORE-INFO***" >> $LOG_FILE
cd /var/crash
ls -ltrh >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "***STORAGE-INFO***" >> $LOG_FILE
du -sh /archive/software/ >> $LOG_FILE
du -sh /cores >> $LOG_FILE
du -sh /var/crash/ >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE
echo "CORE ANALYSIS" >> "$LOG_FILE"

echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Available Core Files ($COUNT)" >> $LOG_FILE
echo "---------------------------------------------------------------------------------------" >> $LOG_FILE
echo
echo "Selected for analysis:" >> $LOG_FILE
echo "  $CORE_GZ" >> $LOG_FILE
echo
echo "Selected binary: $BIN" | tee -a $LOG_FILE
echo "=======================================================================================" >> $LOG_FILE

}


#########################################
# Verify files
#########################################

if [[ ! -f "$CORE_GZ_PATH" ]]; then
    echo "ERROR: Core file not found:"
    echo "       $CORE_GZ_PATH"
    exit 1
fi

if [[ ! -x "$BIN" ]]; then
    echo "ERROR: Executable not found:"
    echo "       $BIN"
    exit 1
fi

#########################################
# Extract core (keep .gz)
#########################################

echo "Extracting core file..."

gunzip -kf "$CORE_GZ_PATH"

#########################################
# Create temporary GDB command file
#########################################

GDB_CMDS=$(mktemp)

cat > "$GDB_CMDS" <<EOF
set pagination off

echo \n===================== BACKTRACE =====================\n
bt

echo \n===================== FULL BACKTRACE =====================\n
bt full

echo \n===================== ALL THREADS BACKTRACE =====================\n
thread apply all bt

quit
EOF



#########################################
# SBC Details
#########################################
hardware_platform


#########################################
# Run GDB
#########################################

echo "Running GDB..."
echo "This may take several minutes..."

gdb "$BIN" "$CORE_PATH" -x "$GDB_CMDS" >> "$LOG_FILE" 2>&1

RET=$?

rm -f "$GDB_CMDS"

#########################################
# Summary
#########################################

echo
echo "==============================================" | tee -a $LOG_FILE
rm $CORE_PATH
chmod 755 $LOG_FILE

echo "GDB analysis completed." | tee -a $LOG_FILE
echo | tee -a $LOG_FILE
echo "Core File : $CORE_GZ_PATH" | tee -a $LOG_FILE
echo "Log File  : $LOG_FILE" | tee -a $LOG_FILE
echo "==============================================" | tee -a $LOG_FILE

exit $RET