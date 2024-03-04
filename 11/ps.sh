#!/bin/bash

printf "%-10s %-10s %-30s %-10s\n" "PID" "TTY" "STAT" "COMMAND"
for PID in /proc/[0-9]*; do
    if [ -d "$PID" ]; then
        PID=$(basename "$PID")
        if [ -f "/proc/$PID/stat" ]; then
            STAT=$(awk '{print $3}' "/proc/$PID/stat")
            TTY=$(awk '{print $7}' "/proc/$PID/stat")
            #CMD=$(awk '{print $2}' "/proc/$PID/stat" | tr -d "()")
            CMD=$(cat "/proc/$PID/cmdline" | tr '\0' ' ' | awk '{$1=$1};1')

            if [ "$TTY" -eq 0 ]; then
                TTY="?"
            else
                TTY=$(ls -l "/proc/$PID/fd/0" | awk '{print $12}')
                TTY=$(echo $TTY | sed 's/\/dev\///')
            fi

            case "$STAT" in
                R) STAT="Running" ;;
                S) STAT="Sleeping" ;;
                D) STAT="Disk Sleep" ;;
                Z) STAT="Zombie" ;;
                T) STAT="Stopped" ;;
                *) STAT="Other" ;;
            esac

            printf "%-10s %-10s %-30s %-10s\n" "$PID" "$TTY" "$STAT" "$CMD"
        fi
    fi
done
