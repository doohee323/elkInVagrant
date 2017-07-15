#!/usr/bin/env bash

set -x

export PROJ_NAME=elk
export USER=ubuntu
export PROJ_DIR=/home/$USER
export SRC_DIR=$PROJ_DIR/tz-elk/resources

# set the ELK package versions
LOGSTASH_VERSION="1:5.4.1-1"

#apt-get update
#apt-get upgrade -y
apt-get install unzip curl -y

#apt-get purge openjdk* -y
add-apt-repository ppa:openjdk-r/ppa 2>&1

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update -y
#apt-get install -y openjdk-8-jdk -y

### [install logstash] ############################################################################################################
echo "[INFO] Installing Logstash..."
apt-get install -y logstash=$LOGSTASH_VERSION
cd /usr/share/logstash/bin
./logstash-plugin install x-pack

cp $SRC_DIR/logstash/logstash.yml /etc/logstash/logstash.yml
mkdir -p /usr/share/logstash/patterns

cp $SRC_DIR/logstash/patterns/nginx /usr/share/logstash/patterns/nginx
cp $SRC_DIR/logstash/log_list/nginx.conf /etc/logstash/conf.d/nginx.conf
cp $SRC_DIR/logstash/log_list/test.conf /etc/logstash/conf.d/test.conf

chown -Rf $USER:$USER /etc/logstash
chown -Rf $USER:$USER /usr/share/logstash
chown -Rf $USER:$USER /var/log/logstash
chown -Rf $USER:$USER /var/lib/logstash

### [geolocation] ############################################################################################################
cd /etc/logstash
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
sudo chown $USER:$USER GeoLite*

sed -i "s/localhost/192.168.82.170/g" /etc/logstash/conf.d/nginx.conf
sed -i "s/localhost/192.168.82.170/g" /etc/logstash/conf.d/test.conf

### [launch logstash] ############################################################################################################
cp $SRC_DIR/logstash/systemd/system/logstash_nginx_aws.service /etc/systemd/system/logstash_nginx.service
bash $SRC_DIR/logstash_register.sh logstash_nginx
systemctl stop logstash_nginx
#systemctl start logstash_nginx
#sudo -u $USER /usr/share/logstash/bin/logstash --path.settings=/etc/logstash -f /etc/logstash/conf.d/nginx.conf &

cp $SRC_DIR/logstash/systemd/system/logstash_test_aws.service /etc/systemd/system/logstash_test.service
bash $SRC_DIR/logstash_register.sh logstash_test
#systemctl stop logstash_test
#systemctl start logstash_test

exit 0
