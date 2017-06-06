#!/usr/bin/env bash

cd /etc/systemd/system

# logstash_register.sh logstash_test1.service
SERVICE=$1
echo $SERVICE

#sudo vi $SERVICE.service
echo sudo systemctl disable $SERVICE
sudo systemctl disable $SERVICE
echo sudo systemctl enable $SERVICE
sudo systemctl enable $SERVICE
echo sudo systemctl stop $SERVICE
sudo systemctl stop $SERVICE
echo sudo systemctl start $SERVICE
sudo systemctl start $SERVICE

# journalctl -f
# sudo systemctl status $SERVICE
# systemctl | grep tomcat

exit 0
