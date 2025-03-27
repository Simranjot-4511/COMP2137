#!/bin/bash

# Default verbose flag
verbose=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -verbose)
            verbose=true
            shift
            ;;
        -name)
            desiredName="$2"
            shift 2
            ;;
        -ip)
            desiredIPAddress="$2"
            shift 2
            ;;
        -hostentry)
            desiredHost="$2"
            desiredIP="$3"
            shift 3
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Function to log changes
log_change() {
    logger "Changed $1 to $2"
}

# Handle hostname change
if [[ -n "$desiredName" ]]; then
    currentName=$(hostname)
    if [[ "$currentName" != "$desiredName" ]]; then
        echo "$desiredName" > /etc/hostname
        sed -i "s/$currentName/$desiredName/" /etc/hosts
        if $verbose; then
            echo "Host name changed from $currentName to $desiredName"
        fi
        log_change "hostname" "$desiredName"
    fi
fi

# Handle IP address change
if [[ -n "$desiredIPAddress" ]]; then
    currentIP=$(hostname -I | awk '{print $1}')
    if [[ "$currentIP" != "$desiredIPAddress" ]]; then
        # Update netplan or network config
        sed -i "s/$currentIP/$desiredIPAddress/" /etc/hosts
        if $verbose; then
            echo "IP address changed from $currentIP to $desiredIPAddress"
        fi
        log_change "IP address" "$desiredIPAddress"
    fi
fi

# Handle host entry update
if [[ -n "$desiredHost" && -n "$desiredIP" ]]; then
    if ! grep -q "$desiredHost" /etc/hosts; then
        echo "$desiredIP $desiredHost" >> /etc/hosts
        if $verbose; then
            echo "Added host entry for $desiredHost with IP $desiredIP"
        fi
        log_change "host entry" "$desiredHost $desiredIP"
    fi
fi
