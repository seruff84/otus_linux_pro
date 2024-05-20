#!/bin/bash

set -o errexit
set -o nounset

# Set the ports that you configured on your server
ports="11111 30456 20299"

# Your server IP
host="192.168.255.1"

for port in $ports ; do
    nmap -Pn --initial-rtt-timeout 10ms --max-retries 0 -p $port $host
done
ssh vagrant@$host