# Найти server_id
SELECT @@server_id;

#####################################################
# На Мастере
#####################################################

# Закрываем и блокируем все таблицы
FLUSH TABLES WITH READ LOCK;

# Смотрим статус Мастера
SHOW MASTER STATUS;

# Создаём пользователя для реплики
CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'Slave#2023'; 
# Даём ему права на репликацию
GRANT REPLICATION SLAVE ON *.* TO repl@'%';


######################################################
# На Слейве
######################################################

# GTID
# необходимо получить публичный ключ
STOP REPLICA;
CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql8master', SOURCE_USER='repl', SOURCE_PASSWORD='Slave#2023', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;

# Binlog position
STOP REPLICA;
CHANGE REPLICATION SOURCE TO SOURCE_HOST='mysql8master', SOURCE_USER='repl', SOURCE_PASSWORD='Slave#2023', SOURCE_LOG_FILE='binlog.000005', SOURCE_LOG_POS=688, GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;


# Сброс реплики
RESET REPLICA;

# https://dev.mysql.com/doc/refman/8.0/en/change-replication-source-to.html

show warnings;

show replica status\G

show global variables like 'gtid_%';

# посмотрим статусы репликации
use performance_schema;
show tables like '%replic%';
show variables like '%log_bin%';
show variables like '%binlog%';
show variables like '%read%';

# Создание таблицы
create table test_tbl (id int);

# Добавляем строчки
insert into test_tbl values (2),(3),(4);

# Создание таблицы
create table test_tbl (id int);

# Добавляем строчки
insert into test_tbl values (2),(3),(4);

#######################################################
# варианты разрешения конфликтов
1. удалить на слейве блокирующую запись
2. STOP SLAVE;
RESET SLAVE;
SHOW SLAVE STATUS; # на мастере
# новый номер позиции в бинлоге

START SLAVE;

3. скипаем 1 ошибку
stop slave; 
set global sql_slave_skip_counter=1; 
start slave;

# скрипт избавления от дубликатов при репликации
while [ 1 ]; do      
if [ `mysql -uroot -ptest -e"show slave status \G;" | grep "Duplicate entry" | wc -l` -eq 2 ] ; then          
mysql -uroot -ptest -e "stop slave; set global sql_slave_skip_counter=1; start slave;";      
fi;      
mysql -uroot -ptest -e "show slave status\G";  
done

4. можно добавить в конфиг игнор ошибки при репликации
ну для duplicate entry например ошибка номер 1062
в конфиг добавляется
slave-skip-errors = 1062



