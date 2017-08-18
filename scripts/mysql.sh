#!/usr/bin/env bash

set -x

### [install mysql] ############################################################################################################
echo "mysql-server mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server -y

if [ -f "/etc/mysql/mysql.conf.d/mysqld.cnf" ]
then
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
else
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
fi

# sudo systemctl status mysql.service
# sudo systemctl stop mysql.service
# sudo systemctl start mysql.service
sudo systemctl restart mysql.service
# mysqladmin -p -u root version
# sudo mysql -u root -p mysql
# passwd123

sudo mysql -u root -ppasswd123 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"
sudo apt-get install ufw
sudo ufw allow 3306
sudo ufw enable -y

# create user / database
sudo mysql -u root -ppasswd123 -e \
"CREATE DATABASE tz_dev; \
CREATE USER tzuser@localhost; \
SET PASSWORD FOR tzuser@localhost= PASSWORD('passwd123'); \
GRANT ALL PRIVILEGES ON tzuser.* TO tzuser@localhost IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"

sudo mysql -u root -ppasswd123 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'tzuser'@'%' IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"

# mysql -u tzuser -h 192.168.82.170 -p tzuser --port 3306

# change password
# UPDATE mysql.user SET Password=PASSWORD('passwd123') WHERE User='tzuser' AND Host='%';
# FLUSH PRIVILEGES;
# or mysqladmin -u아이디 -ptzuser password passwd123

cd /vagrant/resources/mysql
# export
#mysqldump -u tzuser -h 192.168.82.170 -p --add-drop-table tz_dev --port 3306 > tz_dev.sql
#passwd123

# import
#mysql -u tzuser -h 192.168.82.170 -p tz_dev < tz_dev.sql 
#passwd123

exit 0
