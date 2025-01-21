#!/bin/bash

# Check macOS hardware UUID
if [[ "$(uname)" == "Darwin" ]]; then
    uuid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/ {print $4}')
# Check Linux machine ID first
elif [[ -f /etc/machine-id ]]; then
    uuid=$(cat /etc/machine-id)
# Fallback to MAC address, removing colons
else
    mac_address=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address)
    uuid=${mac_address//:/}  # Remove colons from MAC address
fi

echo $uuid
