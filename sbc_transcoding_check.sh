#!/bin/bash

exec 2>/dev/null

CURRENT_TIMESTAMP=$(date)
HOST_NAME=$(hostname)
theSerial=$(dmidecode -t system | grep Serial | awk '{print $3}')
IP_VM=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)
IP_HW=$(ip addr show mgmt | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | head -n1)


LOG_DIR="/var/log"
LOG_FILE=/tmp/sbc_$HOST_NAME-$theSerial-$IP_VM-$IP_HW-license_transcoding_report_$(date +%Y%m%d_%H%M%S).txt

# Find all bnsbc license logs
FILES=$(find "$LOG_DIR" -maxdepth 1 -type f -name 'bnsbc_license-*.log' | sort)

if [ -z "$FILES" ]; then
    echo "ERROR: No bnsbc_license-*.log files found in $LOG_DIR"
    exit 1
fi

# Temporary file for summary information
SUMMARY_FILE=$(mktemp)

trap 'rm -f "$SUMMARY_FILE"' EXIT

{
    echo "=========================================================================="
    echo " BNSBC USED TRANSCODING GATEWAY SESSIONS REPORT"
    echo " Generated : $(date)"
    echo " Log Dir   : $LOG_DIR"
    echo "=========================================================================="
    echo

    echo "=========================================================================="
    echo " COMPLETE DESCENDING LIST"
    echo "=========================================================================="
    echo

    FILE_NUM=0

    while IFS= read -r FILE; do

        FILE_NUM=$((FILE_NUM + 1))
        BASENAME=$(basename "$FILE")

        echo "--------------------------------------------------------------------------"
        echo "$FILE_NUM. $BASENAME"
        echo "--------------------------------------------------------------------------"

        # Extract matching lines.
        # Put the numeric Value first, sort numerically descending,
        # then remove the temporary Value field.
        MATCHES=$(
            grep 'Name=Used-Transcoding-Gateway-Sessions Value=' "$FILE" |
            awk '
            {
                match($0, /Name=Used-Transcoding-Gateway-Sessions Value=-?[0-9]+/)

                if (RSTART > 0) {
                    value = substr($0, RSTART)
                    sub(/^Name=Used-Transcoding-Gateway-Sessions Value=/, "", value)
                    sub(/[^0-9-].*$/, "", value)

                    print value "\t" $0
                }
            }
            ' |
            sort -t$'\t' -k1,1nr
        )

        if [ -n "$MATCHES" ]; then

            # Print complete sorted list
            echo "$MATCHES" | cut -f2-

            # Get maximum Value and corresponding line
            MAX_VALUE=$(echo "$MATCHES" | head -n 1 | cut -f1)
            MAX_LINE=$(echo "$MATCHES" | head -n 1 | cut -f2-)

            # Extract timestamp
            MAX_TIMESTAMP=$(echo "$MAX_LINE" | awk '{print $1 " " $2}')

            # Save summary
            printf "%s|%s|%s\n" \
                "$BASENAME" \
                "$MAX_VALUE" \
                "$MAX_TIMESTAMP" >> "$SUMMARY_FILE"

        else
            echo "No matching Used-Transcoding-Gateway-Sessions entries found."

            printf "%s|%s|%s\n" \
                "$BASENAME" \
                "N/A" \
                "N/A" >> "$SUMMARY_FILE"
        fi

        echo

    done <<< "$FILES"

    echo
    echo "=========================================================================="
    echo " SUMMARY - MAXIMUM TRANSCODING SESSIONS PER LICENSE LOG"
    echo "=========================================================================="
    echo
    printf "%-35s %-12s %-26s\n" "LOG FILE" "MAX SESSIONS" "TIMESTAMP"
    printf "%-35s %-12s %-26s\n" \
        "-----------------------------------" \
        "------------" \
        "--------------------------"

    while IFS='|' read -r FILE_NAME MAX_VALUE MAX_TIMESTAMP; do

        printf "%-35s %-12s %-26s\n" \
            "$FILE_NAME" \
            "$MAX_VALUE" \
            "$MAX_TIMESTAMP"

    done < "$SUMMARY_FILE"

    echo
    echo "=========================================================================="
    echo " END OF REPORT"
    echo "=========================================================================="

} | tee "$LOG_FILE"

echo
echo "Report saved to:"
echo "$LOG_FILE"
 

chmod 755 $LOG_FILE



exit 0;








