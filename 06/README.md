# Стенд Vagrant с NFS 
## Цель домашнего задания 
- Научиться самостоятельно развернуть сервис NFS и подключить к нему клиента 
## Описание домашнего задания 
Основная часть: 
- `vagrant up` должен поднимать 2 настроенных виртуальных машины (сервер NFS и клиента) без дополнительных ручных действий; - на сервере NFS должна быть подготовлена и экспортирована директория; 
- в экспортированной директории должна быть поддиректория с именем __upload__ с правами на запись в неё; 
- экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab -  любым способом); 
- монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3 по протоколу UDP; 
- firewall должен быть включен и настроен как на клиенте, так и на сервере.
Для самостоятельной реализации:
- настроить аутентификацию через KERBEROS с использованием NFSv4. ## Инструкция по выполнению домашнего задания 
Требуется предварительно установленный и работоспособный [Hashicorp  Vagrant](https://www.vagrantup.com/downloads) и [Oracle VirtualBox] (https://www.virtualbox.org/wiki/Linux_Downloads). Также имеет смысл предварительно загрузить образ CentOS 7 2004.01 из Vagrant Cloud  командой ```vagrant box add centos/7 --provider virtualbox --box version 2004.01 --clean```, т.к. предполагается, что дальнейшие действия будут производиться на таких образах.
Все дальнейшие действия были проверены при использовании CentOS  7.9.2009 в качестве хостовой ОС, Vagrant 2.2.18, VirtualBox v6.1.26  и образа CentOS 7 2004.01 из Vagrant Cloud. Серьёзные отступления от этой конфигурации могут потребовать адаптации с вашей стороны.



### Структука каталога:
├── playbook-client.yml # Сценарий настройки клиента
├── playbook-srv.yml    Сценарий настройки 
├── README.md
├── templates
│   ├── kadm5.acl.j2
│   ├── kdc.conf.j2
│   └── krb5.conf.j2
└── Vagrantfile
### Описание файлов: 
playbook-client.yml - Сценарий настройки клиента
playbook-srv.yml - Сценарий настройки сервера
templates - папка с шаблономи конфигурационных файлов
Vagrantfile - Сценарий развертывания ифроструктуры

### Особенности реализаци:
В качесве ос выбрана ubuntu 2204 так как это современный дистрибутив с длительным сроком поддержки.
Так как в этой ос по умочанюи в ядре отключена поддержка UDP для NFS было собрано кастомное ядро.
Подготовка инфораструктуры выполнена с помощью ansible а не bash скриптов как в методичке.

## Настройка  kerberos

 На сервере 
```
kadmin -p defaultuser/admin -w pAssWord -q "addprinc -randkey host/nfss.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "addprinc -randkey host/nfsc.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "addprinc -randkey nfs/nfss.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "addprinc -randkey nfs/nfsc.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "ktadd -randkey host/nfss.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "ktadd -randkey nfs/nfss.lab.local"
```
на клиенте
```
kadmin -p defaultuser/admin -w pAssWord -q "ktadd -randkey host/nfsc.lab.local"
kadmin -p defaultuser/admin -w pAssWord -q "ktadd -randkey nfs/nfsc.lab.local"
```
в `/etc/nfs.conf`
 manage-gids=y 
 vers3=y
 vers4=y
 vers4.0=y
 vers4.1=y
 vers4.2=y

 в `/etc/idmapd.conf`



```
systemctl status rpc-gssd[General]

Verbosity = 0
# set your own domain here, if it differs from FQDN minus hostname
# Domain = localdomain
Domain = lab.local
Local-Realms = LAB.LOCAL
[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup

[Translation]
Method = nsswitch,static
GSS-Methods = nsswitch,static
```
В  `/etc/exports` :

```
/srv/share  192.168.50.11/32(rw,sync,insecure,no_root_squash,no_subtree_check,sec=krb5:krb5i:krb5p)
```
на клиенте 

`mount -vvv -t nfs4 -o sec=krb5 nfss.lab.local:/srv/share /nfs`

в результате ошибка:

mount.nfs4: mount(2): Operation not permitted
mount.nfs4: Operation not permitted