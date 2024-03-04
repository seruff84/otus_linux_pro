#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <PID>"
    exit 1
fi

PID=$1
if [ ! -d "/proc/$PID" ]; then
    echo "Process with PID $PID not found."
    exit 1
fi

printf "%-10s %-10s %-30s %-10s\n" "PID" "FD" "Device type" "File"
for FD in $(ls /proc/$PID/fd); do
    FILE=$(readlink /proc/$PID/fd/$FD)
    if [ -n "$FILE" ]; then
        if [[ "$FILE" == "socket:"* ]]; then
            TYPE="socket"
            ID=$(echo "$FILE" | cut -d':' -f2)
            printf "%-10s %-10s %-30s %-10s\n" "$PID" "$FD" "$TYPE" "socket $ID"
        elif [[ "$FILE" == "pipe:"* ]]; then
            TYPE="pipe"
            ID=$(echo "$FILE" | cut -d':' -f2)
            printf "%-10s %-10s %-30s %-10s\n" "$PID" "$FD" "$TYPE" "pipe $ID"
        else
            TYPE=$(file -b "$FILE")
            printf "%-10s %-10s %-30s %-10s\n" "$PID" "$FD" "$TYPE" "$FILE"
          
        fi
       
    fi
done
