### Домашнее задание по теме PAM

#### Цель домашнего задания
Научиться создавать пользователей и добавлять им ограничения

#### Описание домашнего задания
1. Запретить всем пользователям кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

* дать конкретному пользователю права работать с докером и возможность перезапускать докер сервис

#### Реализация

##### Запретить всем пользователям кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

Задание реализована с использованием модуля `pam_exec`.
К заданию приложен Vagrant файл и плейбук Ansible для настройки стенда.



##### дать конкретному пользователю права работать с докером и возможность перезапускать докер сервис

Так как это учебное задание предположу что просто добавить этого пользователя в групп Docker не является решением.
Тогда для решения это задачи можно создать политику для Polkit разрешающую пепрезапуск севиса:
```
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        action.lookup("unit") == "docker.service" &&
        subject.user == "otus") {
        return polkit.Result.YES;
    }
});
```

Но так как для это домашней работы предлагается использовать Ubuntu, а в ней версия polkit 0.105, то нельзя использовать такие политики и нужно использовать другой вариант. Тогда политика будет выглядеть слудующим образом:

```
[Allow user otus to run systemctl commands]
Identity=unix-user:otus
Action=org.freedesktop.systemd1.manage-units
ResultInactive=no
ResultActive=no
ResultAny=yes
```

Для того чтобы предоставить пользователю otus право запускать контейнеры нужно дать ему права на сокет /var/run/docker.sock.
Так как задача учебная, то это можно сделать добавив в файл юнита
/lib/systemd/system/docker.socket опцию `ExecStartPost=/usr/bin/setfacl -m u:otus:rw /var/run/docker.sock`. Результирующий файл будет выглядеть следующим образом:

```
[Unit]
Description=Docker Socket for the API

[Socket]
# If /var/run is not implemented as a symlink to /run, you may need to
# specify ListenStream=/var/run/docker.sock instead.
ListenStream=/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
ExecStartPost=/usr/bin/setfacl -m u:otus:rw /var/run/docker.sock
[Install]
WantedBy=sockets.target
```

Полсле чего выполнить комаду `systemctl daemon-reload`.