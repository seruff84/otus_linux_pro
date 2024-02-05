apt update
apt install -y zfsutils-linux
zpool create otus1 mirror /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy1-lun-0 /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy2-lun-0
zpool create otus2 mirror /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy3-lun-0 /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy4-lun-0
zpool create otus3 mirror /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy5-lun-0 /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy6-lun-0
zpool create otus4 mirror /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy7-lun-0 /dev/disk/by-path/pci-0000\:00\:16.0-sas-phy8-lun-0
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
printf  "Проверим, что файл был скачан во все пулы:\n" >> /tmp/HW.log
ls -l /otus* >> /tmp/HW.log
printf "\nПроверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:\n" >> /tmp/HW.log
zfs list  >> /tmp/HW.log
zfs get all | grep compressratio | grep -v ref >> /tmp/HW.log
cd ~
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
tar -xzvf archive.tar.gz
printf "\n Проверим, возможно ли импортировать данный каталог в пул:\n" >> /tmp/HW.log
zpool import -d zpoolexport/ >> /tmp/HW.log
zpool import -d zpoolexport/ otus
printf "\nСделаем импорт данного пула к нам в ОС:\n" >> /tmp/HW.log
zpool status >> /tmp/HW.log
printf "\nЗапрос сразу всех параметром файловой системы: zfs get all otus\n"
zfs get all otus  >> /tmp/HW.log
printf "\nРазмер: zfs get available otus\n" >> /tmp/HW.log
zfs get available otus >> /tmp/HW.log
printf "\n Тип: zfs get readonly otus\n" >> /tmp/HW.log
zfs get readonly otus >> /tmp/HW.log
printf "\nЗначение recordsize: zfs get recordsize otus\n" >> /tmp/HW.log
zfs get recordsize otus >> /tmp/HW.log
printf "\nТип сжатия (или параметр отключения): zfs get compression otus\n" >> /tmp/HW.log
zfs get compression otus >> /tmp/HW.log
printf "\nТип контрольной суммы: zfs get checksum otus\n" >> /tmp/HW.log
zfs get checksum otus >> /tmp/HW.log
wget -O otus_task2.file --no-check-certificate 'https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download'
zfs receive otus/test@today < otus_task2.file
printf "\nищем в каталоге /otus/test файл с именем 'secret_message':\n" >> /tmp/HW.log
find /otus/test -name "secret_message" >> /tmp/HW.log
printf "\nСмотрим содержимое найденного файла:\n" >> /tmp/HW.log
cat /otus/test/task1/file_mess/secret_message >> /tmp/HW.log







