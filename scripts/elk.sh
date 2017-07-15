#!/usr/bin/env bash

set -x

export PROJ_NAME=elk
export USER=vagrant
export PROJ_DIR=/home/$USER
export SRC_DIR=/vagrant/resources

# set the ELK package versions
ELASTIC_VERSION=5.4.1
ELASTICSEARCH_VERSION=5.4.1
LOGSTASH_VERSION=1:5.4.1-1
KIBANA_VERSION=5.4.1

echo '' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc
echo 'export USER=vagrant' >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc
echo 'export ELASTIC_VERSION='$ELASTIC_VERSION >> $PROJ_DIR/.bashrc
echo 'export ELASTICSEARCH_VERSION='$ELASTICSEARCH_VERSION >> $PROJ_DIR/.bashrc
echo 'export LOGSTASH_VERSION='$LOGSTASH_VERSION >> $PROJ_DIR/.bashrc
echo 'export KIBANA_VERSION='$KIBANA_VERSION >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get install unzip curl -y

apt-get purge openjdk* -y
add-apt-repository ppa:openjdk-r/ppa 2>&1

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
rm -Rf node1 node2 node3
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update -y
apt-get install -y openjdk-8-jdk -y

echo "[INFO] Installing Elasticsearch..."
apt-get install -y elasticsearch=$ELASTICSEARCH_VERSION
update-rc.d elasticsearch defaults 95 10

# isntall x-pack
cd /usr/share/elasticsearch/bin
#./elasticsearch-plugin remove x-pack
./elasticsearch-plugin install --b x-pack 

cp $SRC_DIR/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/
service elasticsearch stop

# make 2 elasticsearch servers
cd $SRC_DIR/elasticsearch
bash make_es.sh es1
bash make_es.sh es2
service es1 start
service es2 start

### [cerebro] ############################################################################################################
cd $PROJ_DIR
wget https://github.com/lmenezes/cerebro/releases/download/v0.6.5/cerebro-0.6.5.tgz
tar xvfz cerebro-0.6.5.tgz
cd $PROJ_DIR/cerebro-0.6.5/bin
cp $SRC_DIR/cerebro/application.conf $PROJ_DIR/cerebro-0.6.5/conf/application.conf
rm -Rf $PROJ_DIR/cerebro-0.6.5/RUNNING_PID
./cerebro &
# http://localhost:9000

### [nginx] ############################################################################################################
apt-get install nginx -y
sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
service nginx stop
nginx -s stop
nginx
# curl http://127.0.0.1:8080

### [install logstash] ############################################################################################################
echo "[INFO] Installing Logstash..."
apt-get install -y logstash=$LOGSTASH_VERSION
cd /usr/share/logstash/bin
./logstash-plugin install x-pack

cp $SRC_DIR/logstash/logstash.yml /etc/logstash/logstash.yml
mkdir -p /usr/share/logstash/patterns

cp $SRC_DIR/logstash/patterns/nginx /usr/share/logstash/patterns/nginx
cp $SRC_DIR/logstash/log_list/nginx.conf /etc/logstash/conf.d/nginx.conf

chown -Rf $USER:$USER /etc/logstash
chown -Rf $USER:$USER /usr/share/logstash
chown -Rf $USER:$USER /var/log/logstash
chown -Rf $USER:$USER /var/lib/logstash

### [geolocation] ############################################################################################################
cd /etc/logstash
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
sudo chown $USER:$USER GeoLite*

### [launch logstash] ############################################################################################################
cp $SRC_DIR/logstash/systemd/system/logstash_nginx.service /etc/systemd/system/logstash_nginx.service
bash $SRC_DIR/logstash_register.sh logstash_nginx
systemctl stop logstash_nginx
systemctl start logstash_nginx
#sudo -u $USER /usr/share/logstash/bin/logstash --path.settings=/etc/logstash -f /etc/logstash/conf.d/nginx.conf &

cp $SRC_DIR/logstash/systemd/system/logstash_nginx.service /etc/systemd/system/logstash_nginx.service
bash $SRC_DIR/logstash_register.sh logstash_nginx
#systemctl stop logstash_nginx
#systemctl start logstash_nginx

### [install kibana] ############################################################################################################
echo "[INFO] Installing Kibana..."
apt-get install -y kibana=$KIBANA_VERSION

# install x-pack
cd /usr/share/kibana/bin
./kibana-plugin install x-pack
update-rc.d kibana defaults 96 9
cp -R $SRC_DIR/kibana/kibana.yml /etc/kibana/kibana.yml
service kibana start

### [service restart] ############################################################################################################
service es1 restart
#service es2 restart
service kibana restart
systemctl restart logstash_nginx

### [add user & role] ############################################################################################################
bash $SRC_DIR/elasticsearch/queries/add_user_role.sh

# make nginx access log
curl http://localhost:8080

### [make template & mapping] ############################################################################################################
bash $SRC_DIR/elasticsearch/queries/template.sh
bash $SRC_DIR/elasticsearch/queries/reset_mapping.sh

cd $PROJ_DIR/cerebro-0.6.5/bin
rm -Rf $PROJ_DIR/cerebro-0.6.5/RUNNING_PID
killall cerebro
./cerebro &

### [make test data] ############################################################################################################
mkdir -p $PROJ_DIR/data
cp $SRC_DIR/data/stats-2017-02-22.log /opt/tomcat/data
chown -Rf vagrant:vagrant $PROJ_DIR

exit 0
