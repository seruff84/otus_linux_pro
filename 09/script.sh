
cat >> /etc/sysconfig/watchlog << EOF
	# Configuration file for my watchlog service
	# Place it to /etc/sysconfig

	# File and word in that file that we will be monit
	WORD="ALERT"
	LOG=/var/log/watchlog.log
EOF
touch /var/log/watchlog.log
cat >> /opt/watchlog.sh << EOF
  #!/bin/bash
  WORD=$1
  LOG=$2
  DATE=`date`
  if grep $WORD $LOG &> /dev/null
  then
  logger "$DATE: I found word, Master!"
  else
  exit 0
  fi
EOF
chmod +x /opt/watchlog.sh