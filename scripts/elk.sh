#!/usr/bin/env bash

set -x

export PROJ_NAME=elk
export PROJ_DIR=/home/vagrant
export SRC_DIR=/vagrant/resources

echo '' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

# set the ELK package versions
ELASTIC_VERSION="5.3.0"
ELASTICSEARCH_VERSION=$ELASTIC_VERSION
#LOGSTASH_VERSION=$ELASTIC_VERSION
KIBANA_VERSION=$ELASTIC_VERSION

apt-get update
apt-get upgrade -y
apt-get install unzip curl -y

apt-get purge openjdk*
add-apt-repository ppa:openjdk-r/ppa 2>&1
apt-get update
apt-get install -y openjdk-8-jdk

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
rm -Rf node1 node2 node3
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update

echo "[INFO] Installing Elasticsearch..."
apt-get install -y elasticsearch=$ELASTICSEARCH_VERSION
update-rc.d elasticsearch defaults 95 10

#cp /vagrant/provision/elasticsearch/elasticsearch.yml /etc/elasticsearch/
cp /vagrant/resources/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/
#cp /vagrant/resources/elasticsearch/config/elasticsearch.yml /etc/es1/
service elasticsearch stop

# make 2 elasticsearch servers
cd /vagrant/resources/elasticsearch
bash make_es.sh es1
bash make_es.sh es2
service es1 start
service es2 start

### [cerebro] ############################################################################################################
cd $PROJ_DIR
wget https://github.com/lmenezes/cerebro/releases/download/v0.6.5/cerebro-0.6.5.tgz
tar xvfz cerebro-0.6.5.tgz
cd /home/vagrant/cerebro-0.6.5/bin
sudo cp $SRC_DIR/cerebro/application.conf /home/vagrant/cerebro-0.6.5/conf
rm -Rf /home/vagrant/cerebro-0.6.5/RUNNING_PID
./cerebro &
# http://core.local.xdn.com:9000
# http://localhost:9200

### [nginx] ############################################################################################################
apt-get install nginx -y
sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
service nginx stop
sudo nginx -s stop
sudo nginx
# curl http://127.0.0.1:8080

### [install logstash] ############################################################################################################
echo "[INFO] Installing Logstash..."
apt-get install -y logstash=1:5.3.1-1
cp $SRC_DIR/logstash/logstash.yml /etc/logstash/logstash.yml
mkdir /etc/logstash/patterns

cp $SRC_DIR/logstash/patterns/nginx /etc/logstash/patterns/
cp $SRC_DIR/logstash/log_list/nginx.conf /etc/logstash/conf.d/

chown -Rf vagrant:vagrant /etc/logstash
chown -Rf vagrant:vagrant /usr/share/logstash
chown -Rf vagrant:vagrant /var/log/logstash
chown -Rf vagrant:vagrant /var/lib/logstash

### [geolocation] ############################################################################################################
cd /etc/logstash
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
sudo chown vagrant:vagrant GeoLite*

### [launch logstash] ############################################################################################################
cp $SRC_DIR/logstash/systemd/system/logstash_nginx.service /etc/systemd/system/logstash_nginx.service
bash $SRC_DIR/logstash_register.sh logstash_nginx
systemctl stop logstash_nginx
systemctl start logstash_nginx
#sudo -u vagrant /usr/share/logstash/bin/logstash --path.settings=/etc/logstash -f /etc/logstash/conf.d/nginx.conf &

### [install kibana] ############################################################################################################
echo "[INFO] Installing Kibana..."
apt-get install -y kibana=$KIBANA_VERSION
update-rc.d kibana defaults 96 9
cp -R /vagrant/resources/kibana/kibana.yml /etc/kibana/
service kibana start

### [make test data] ############################################################################################################
mkdir -p $PROJ_DIR/data
cp $SRC_DIR/data/stats-2017-02-22.log /opt/tomcat/data
chown -Rf vagrant:vagrant $PROJ_DIR

### [update mapping for geolocation] ############################################################################################################
bash $SRC_DIR/elasticsearch/queries/reset_mapping.sh

exit 0
