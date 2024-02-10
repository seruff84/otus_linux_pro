mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
rm -f /etc/yum.repos.d/otus.repo
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum update -y
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc 
cd /root
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
rpm -i nginx-1.*
cp /tmp/nginx.spec /root/rpmbuild/SPECS/nginx.spec
yum-builddep rpmbuild/SPECS/nginx.spec -y
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
unzip -o OpenSSL_1_1_1-stable.zip
mv -f openssl-OpenSSL_1_1_1-stable openssl-1.1.1a
rpmbuild -bb rpmbuild/SPECS/nginx.spec
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
systemctl start nginx
mkdir -p /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
createrepo /usr/share/nginx/html/repo/
sed -i 's/        index  index.html index.htm;/        index  index.html index.htm;\n        autoindex on;/' /etc/nginx/conf.d/default.conf
systemctl reload nginx
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
yum repolist enabled | grep otus
yum install percona-orchestrator.x86_64 -y
