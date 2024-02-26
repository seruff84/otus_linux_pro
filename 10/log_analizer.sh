#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
LAST_RUN_FILE="/tmp/nginx_log_analyzer_last_run"
EMAIL="test@lab.local"

if [ -f /tmp/nginx_log_analyzer.lock ]; then
    echo "Script is already running, exiting."
    exit 1
fi

touch /tmp/nginx_log_analyzer.lock

cleanup() {
    rm -f /tmp/nginx_log_analyzer.lock
}
trap cleanup EXIT

if [ ! -f $LAST_RUN_FILE ]; then
    echo "0" > $LAST_RUN_FILE
fi

LAST_RUN=$(cat $LAST_RUN_FILE)
LOG_DATA=$(awk -v last_run="$LAST_RUN" '$4 > last_run' $LOG_FILE)
TOP_IP=$(echo "$LOG_DATA" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 10)
TOP_URL=$(echo "$LOG_DATA" | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 10)
ERRORS=$(echo "$LOG_DATA" | awk '$9 >= 400 {print $9}')
HTTP_CODES=$(echo "$LOG_DATA" | awk '{print $9}' | sort | uniq -c | sort -nr)


echo -e "From: nginx_log_analyzer@example.com\nTo: $EMAIL\nSubject: Nginx Log Analysis Report\n\n\
Time range: $(date -d @$LAST_RUN) - $(date)\n\n\
Top IP addresses:\n$TOP_IP\n\n\
Top requested URLs:\n$TOP_URL\n\n\
Server/application errors:\n$ERRORS\n\n\
HTTP response codes:\n$HTTP_CODES" | /usr/sbin/sendmail -t
echo "Report sent to $EMAIL"

echo $(date +%s) > $LAST_RUN_FILE
