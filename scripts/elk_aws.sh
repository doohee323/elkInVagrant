#!/usr/bin/env bash

set -x

export PROJ_NAME=elk
export PROJ_DIR=/home/vagrant
export SRC_DIR=/home/vagrant/tz-elk/resources

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

git clone https://github.com/doohee323/tz-elk.git

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
rm -Rf node1 node2 node3
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' | tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update

echo "[INFO] Installing Elasticsearch..."
apt-get install -y elasticsearch=$ELASTICSEARCH_VERSION
update-rc.d elasticsearch defaults 95 10

#cp /ubuntu/provision/elasticsearch/elasticsearch.yml /etc/elasticsearch/
cp /ubuntu/resources/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/
#cp /ubuntu/resources/elasticsearch/config/elasticsearch.yml /etc/es1/
service elasticsearch stop

# make 2 elasticsearch servers
cd /ubuntu/resources/elasticsearch
bash make_es.sh es1
bash make_es.sh es2
service es1 start
service es2 start

### [install cloud-aws] ############################################################################################################
$PROJ_DIR/node1/bin/plugin install cloud-aws -b
$PROJ_DIR/node2/bin/plugin install cloud-aws -b
$PROJ_DIR/node3/bin/plugin install cloud-aws -b

### [cerebro] ############################################################################################################
cd $PROJ_DIR
wget https://github.com/lmenezes/cerebro/releases/download/v0.6.5/cerebro-0.6.5.tgz
tar xvfz cerebro-0.6.5.tgz
rm -Rf /usr/share/cerebro-0.6.5
mv cerebro-0.6.5 /usr/share/cerebro-0.6.5
cp $SRC_DIR/cerebro/application.conf /usr/share/cerebro-0.6.5/conf/application.conf
cp $SRC_DIR/cerebro/systemd/system/cerebro_aws.service /etc/systemd/system/cerebro.service
cd /etc/systemd/system
systemctl enable cerebro
systemctl start cerebro
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

chown -Rf ubuntu:ubuntu /etc/logstash
chown -Rf ubuntu:ubuntu /usr/share/logstash
chown -Rf ubuntu:ubuntu /var/log/logstash
chown -Rf ubuntu:ubuntu /var/lib/logstash

### [geolocation] ############################################################################################################
cd /etc/logstash
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
sudo chown ubuntu:ubuntu GeoLite*

### [launch logstash] ############################################################################################################
cp $SRC_DIR/logstash/systemd/system/logstash_nginx.service /etc/systemd/system/logstash_nginx.service
bash $SRC_DIR/logstash_register.sh logstash_nginx
systemctl stop logstash_nginx
systemctl start logstash_nginx
#sudo -u ubuntu /usr/share/logstash/bin/logstash --path.settings=/etc/logstash -f /etc/logstash/conf.d/nginx.conf &

### [install kibana] ############################################################################################################
echo "[INFO] Installing Kibana..."
apt-get install -y kibana=$KIBANA_VERSION
update-rc.d kibana defaults 96 9
cp -R /ubuntu/resources/kibana/kibana.yml /etc/kibana/
service kibana start

### [make test data] ############################################################################################################
mkdir -p $PROJ_DIR/data
cp $SRC_DIR/data/stats-2017-02-22.log /opt/tomcat/data
chown -Rf ubuntu:ubuntu $PROJ_DIR

### [update mapping for geolocation] ############################################################################################################
bash $SRC_DIR/elasticsearch/queries/reset_mapping.sh

exit 0
