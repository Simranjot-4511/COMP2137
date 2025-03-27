#!/bin/bash

# Check if verbose flag is set
verbose=false
if [[ "$1" == "-verbose" ]]; then
    verbose=true
fi

# Define remote servers
server1="remoteadmin@server1-mgmt"
server2="remoteadmin@server2-mgmt"

# Copy configure-host.sh to server1 and run it
scp configure-host.sh $server1:/root
ssh $server1 "bash /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 $(if $verbose; then echo '-verbose'; fi)"

# Copy configure-host.sh to server2 and run it
scp configure-host.sh $server2:/root
ssh $server2 "bash /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 $(if $verbose; then echo '-verbose'; fi)"

# Run locally for updating /etc/hosts
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
