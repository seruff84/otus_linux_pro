#!/bin/bash
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
yum install -y epel-release
yum install -y nano setroubleshoot-server selinux-policy-mls setools-console policycoreutils-python policycoreutils-newrole nginx
sed -Ei 's/(listen[[:space:]]*)80/\19081/g' /etc/nginx/nginx.conf
systemctl enable nginx