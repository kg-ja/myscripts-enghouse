#!/bin/bash

INTERFACES=("eth2" "eth3")

echo "Starting gratuitous ARP announcements..."

for INTERFACE in "${INTERFACES[@]}"; do

    # Get all IPv4 addresses for this interface
    IPS=$(ip -4 -o addr show dev "$INTERFACE" | awk '{print $4}' | cut -d/ -f1)

    if [ -z "$IPS" ]; then
        echo "No IPv4 addresses found on $INTERFACE"
        continue
    fi

    echo "Processing interface: $INTERFACE"

    for IP in $IPS; do
        echo "  Announcing IP: $IP on $INTERFACE"
        arping -U -c 5 -I "$INTERFACE" "$IP"
    done

done

echo "Gratuitous ARP announcements complete."