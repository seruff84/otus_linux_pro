##################

#!/bin/bash

PATH=$PATH:/usr/local/bin
MYSQL='mysql --skip-column-names'

for s in mysql `$MYSQL -e "SHOW DATABASES LIKE '%\_db'"`;
    do
	mkdir $s;
	/usr/bin/mysqldump --add-drop-table --add-locks --create-options --disable-keys --extended-insert --single-transaction --quick --set-charset --events --routines --triggers  $s | gzip -1 > $s/$s.gz;
    done

pt-show-grants > grants.sql

##################
# Mydumper
mydumper --user=root --password=NykArNq1 --directory=/home/db/back
myloader --user=root --password=NykArNq1 --directory=./

################## 
# Xtrabackup
apt install percona-xtrabackup-80
xtrabackup --user=root --password=1 --backup --target-dir=/home/db/backups/
xtrabackup --prepare --target-dir=/home/db/backups/

# Сжатый бэкап
xtrabackup --user=root --password=NykArNq1 --compress=lz4 --compress-threads=4 --backup --target-dir=/home/db/backups/

xtrabackup --decompress --parallel=4 --remove-original --target-dir=/home/db/backups/

xtrabackup --prepare --target-dir=/home/db/backups/

# Восстановление
xtrabackup --prepare --target-dir=/home/db/backups/

systemctl stop mysql

rm -rf /var/lib/mysql/*
chown -R mysql:mysql /var/lib/mysql

xtrabackup --copy-back || --move-back --target-dir=/home/db/backups/

systemctl start mysql

##################################################3
# Stream
# режим STREAM направляет поток в STDOUT в формате xbstream, а STDOUT уже
# можно перенаправить куда угодно
# направляем поток в файл
xtrabackup --backup --stream=xbstream --target-dir=./ > backup.xbstream

# с компрессией
xtrabackup --backup --stream=xbstream --compress --target-dir=./ > backup.xbstream

# с шифрованием
xtrabackup --backup --stream=xbstream | gzip - | openssl des3 -salt -k “password” > backup.xbstream.gz.des3

# расшифровка
openssl des3 -salt -k “password” -d -in backup.xbstream.gx.des3 -out backup.xbstream.gz
gzip -d backup.xbstream.gz

# распаковка файла xbstream
xbstream -x < backup.xbstream

# На другой сервер
xtrabackup --backup --compress --stream=xbstream --target-dir=./ | ssh
xtrabackup@<ip_address> “xbstream -x -C backup”

# слушаем на приемщике
nc -l 9999 | cat - > /data/backup/backup.xbstream

# Отсылаем с сервера базы
xtrabackup --backup --stream=xbstream ./ | nc desthost 9999




