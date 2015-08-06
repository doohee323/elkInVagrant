#!/usr/bin/env bash

# Get root up in here
sudo su

set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

PROJ_NAME=elk
PROJ_DIR=/home/vagrant

echo '' >> $PROJ_DIR/.bashrc
echo 'PATH=$PATH:.' >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

apt-get update
apt-get install openjdk-7-jdk -y
apt-get install nginx -y

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.1.tar.gz
tar xzvf elasticsearch-1.7.1.tar.gz
mv elasticsearch-1.7.1 $PROJ_DIR/node1
sudo chown -Rf vagrant:vagrant $PROJ_DIR/node1
cp /vagrant/resources/elasticsearch/config/elasticsearch.yml $PROJ_DIR/node1/config/elasticsearch.yml
cp /vagrant/resources/elasticsearch/start.sh $PROJ_DIR/node1
cp /vagrant/resources/elasticsearch/stop.sh $PROJ_DIR/node1
cp /vagrant/resources/elasticsearch/startall.sh $PROJ_DIR
cp /vagrant/resources/elasticsearch/stopall.sh $PROJ_DIR
chmod 777 $PROJ_DIR/node1/*.sh
chmod 777 $PROJ_DIR/*.sh
$PROJ_DIR/startall.sh

### [install elasticsearch-kopf] ############################################################################################################
$PROJ_DIR/node1/bin/plugin --install lmenezes/elasticsearch-kopf/1.5.7
# https://github.com/lmenezes/elasticsearch-kopf
# http://localhost:9200/_plugin/kopf

### [install elasticsearch-head] ############################################################################################################
$PROJ_DIR/node1/bin/plugin  -install mobz/elasticsearch-head
# https://github.com/mobz/elasticsearch-head
# http://localhost:9200/_plugin/head

### [install bigdesk] ############################################################################################################
$PROJ_DIR/node1/bin/plugin  -install lukas-vlcek/bigdesk 
# http://localhost:9200/_plugin/bigdesk

### [install logstash] ############################################################################################################
cd $PROJ_DIR
wget https://download.elastic.co/logstash/logstash/logstash-1.5.3.tar.gz
tar xvfz logstash-1.5.3.tar.gz
mkdir $PROJ_DIR/logstash-1.5.3/patterns
mkdir $PROJ_DIR/logstash-1.5.3/log_list
cp /vagrant/resources/logstash/patterns/nginx $PROJ_DIR/logstash-1.5.3/patterns
cp /vagrant/resources/logstash/log_list/nginx.conf $PROJ_DIR/logstash-1.5.3/log_list

$PROJ_DIR/logstash-1.5.3/bin/logstash -f $PROJ_DIR/logstash-1.5.3/log_list/nginx.conf -t
$PROJ_DIR/logstash-1.5.3/bin/logstash -f $PROJ_DIR/logstash-1.5.3/log_list/nginx.conf &

### [install kibana] ############################################################################################################
cd $PROJ_DIR
wget https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz
tar xzvf kibana-4.1.1-linux-x64.tar.gz
$PROJ_DIR/kibana-4.1.1-linux-x64/bin/kibana > /dev/null 2>&1 &
# http://localhost:5601

### [conf nginx] ############################################################################################################
cp /vagrant/resources/nginx/nginx.conf /etc/nginx/nginx.conf
#http {
#    log_format main '$http_host '
#                    '$remote_addr [$time_local] '
#                    '"$request" $status $body_bytes_sent '
#                    '"$http_referer" "$http_user_agent" '
#                    '$request_time '
#                    '$upstream_response_time';
#    access_log  /var/log/nginx/access.log  main;
#}
nginx -s stop
nginx
# curl http://127.0.0.1:8080
cp /vagrant/resources/init/$PROJ_NAME.conf /etc/init/$PROJ_NAME.conf


### [etc tools] ############################################################################################################
apt-get install python-software-properties python-setuptools libtool autoconf automake uuid-dev build-essential wget curl git monit -y
apt-get install ganglia-monitor -y

cp /vagrant/resources/ganglia/gmond.conf /etc/ganglia/gmond.conf
sed -i "s/THISNODEID/$cfg_ganglia_nodes_prefix-$PROJ_NAME/g" /etc/ganglia/gmond.conf
sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/ganglia/gmond.conf

mkdir -p /etc/jmxetric
cp /vagrant/resources/jmxetric/$PROJ_NAME.xml /etc/jmxetric/$PROJ_NAME.xml
cp /vagrant/resources/init/jmxetric_$PROJ_NAME.conf /etc/init/jmxetric_$PROJ_NAME.conf
sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/jmxetric/$PROJ_NAME.xml
sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/init/jmxetric_$PROJ_NAME.conf

# /etc/init.d/ganglia-monitor restart

mkdir /opt/$PROJ_NAME
mkdir /opt/$PROJ_NAME/log
mkdir /opt/run 
cd /opt/$PROJ_DIR
wget http://central.maven.org/maven2/info/ganglia/jmxetric/jmxetric/1.0.4/jmxetric-1.0.4.jar
wget http://central.maven.org/maven2/info/ganglia/gmetric4j/gmetric4j/1.0.10/gmetric4j-1.0.10.jar
wget http://central.maven.org/maven2/org/acplt/oncrpc/1.0.7/oncrpc-1.0.7.jar
service jmxetric_$PROJ_NAME restart

