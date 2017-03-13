#!/usr/bin/env bash

set -x

export PROJ_NAME=elk
export PROJ_DIR=/home/ubuntu
export SRC_DIR=/home/ubuntu/tz-elk/resources

# scp -i dev.pem /Users/dhong/Documents/workspace/sts-3.8.3.RELEASE/tz-elk/resources.zip ubuntu@13.124.42.39:/home/ubuntu

echo '' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

sudo apt-get update
sudo apt-get install openjdk-8-jdk curl -y
sudo apt-get install nginx -y
sudo apt-get install systemd-services -y

git clone https://github.com/doohee323/tz-elk.git

### [install elasticsearch] ############################################################################################################
cd $PROJ_DIR
rm -Rf node1 node2 node3
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.2.0.tar.gz
tar xzvf elasticsearch-2.2.0.tar.gz
mv elasticsearch-2.2.0 $PROJ_DIR/node1
chown -Rf ubuntu:ubuntu $PROJ_DIR/node1
cp $SRC_DIR/elasticsearch/config/elasticsearch_aws.yml $PROJ_DIR/node1/config/elasticsearch.yml
cp $SRC_DIR/elasticsearch/start.sh $PROJ_DIR/node1
cp $SRC_DIR/elasticsearch/stop.sh $PROJ_DIR/node1
cp $SRC_DIR/elasticsearch/startall.sh $PROJ_DIR
cp $SRC_DIR/elasticsearch/stopall.sh $PROJ_DIR

sed -i "s/vagrant/ubuntu/g" $PROJ_DIR/node1/start.sh
sed -i "s/vagrant/ubuntu/g" $PROJ_DIR/node1/stop.sh
sed -i "s/vagrant/ubuntu/g" $PROJ_DIR/startall.sh
sed -i "s/vagrant/ubuntu/g" $PROJ_DIR/stopall.sh

chmod 777 $PROJ_DIR/node1/*.sh
chmod 777 $PROJ_DIR/*.sh

### [copy elasticsearch nodes] ############################################################################################################
cd $PROJ_DIR
cp -Rf $PROJ_DIR/node1 $PROJ_DIR/node2
cp -Rf $PROJ_DIR/node1 $PROJ_DIR/node3
chown -Rf ubuntu:ubuntu $PROJ_DIR/node2
chown -Rf ubuntu:ubuntu $PROJ_DIR/node3

sed -i "s/node1/node2/g" $PROJ_DIR/node2/config/elasticsearch.yml
sed -i "s/9300/9302/g" $PROJ_DIR/node2/config/elasticsearch.yml
sed -i "s/9200/9202/g" $PROJ_DIR/node2/config/elasticsearch.yml

sed -i "s/node1/node2/g" $PROJ_DIR/node2/start.sh
sed -i "s/es1/es2/g" $PROJ_DIR/node2/start.sh
sed -i "s/node1/node2/g" $PROJ_DIR/node2/stop.sh
sed -i "s/es1/es2/g" $PROJ_DIR/node2/stop.sh

sed -i "s/node1/node3/g" $PROJ_DIR/node3/config/elasticsearch.yml
sed -i "s/9300/9303/g" $PROJ_DIR/node3/config/elasticsearch.yml
sed -i "s/9200/9203/g" $PROJ_DIR/node3/config/elasticsearch.yml

sed -i "s/node1/node3/g" $PROJ_DIR/node3/start.sh
sed -i "s/es1/es3/g" $PROJ_DIR/node3/start.sh

sed -i "s/node1/node3/g" $PROJ_DIR/node3/stop.sh
sed -i "s/es1/es3/g" $PROJ_DIR/node3/stop.sh

chown -Rf ubuntu:ubuntu $PROJ_DIR

### [install cloud-aws] ############################################################################################################
$PROJ_DIR/node1/bin/plugin install cloud-aws -b
$PROJ_DIR/node2/bin/plugin install cloud-aws -b
$PROJ_DIR/node3/bin/plugin install cloud-aws -b

echo "run all 3 nodes!"
sudo -u ubuntu $PROJ_DIR/startall.sh

### [install elasticsearch-kopf] ############################################################################################################
$PROJ_DIR/node1/bin/plugin install lmenezes/elasticsearch-kopf/2.1.1

# https://github.com/lmenezes/elasticsearch-kopf
# http://localhost:9200/_plugin/kopf

### [install elasticsearch-head] ############################################################################################################
$PROJ_DIR/node1/bin/plugin  install mobz/elasticsearch-head
# https://github.com/mobz/elasticsearch-head
# http://localhost:9200/_plugin/head

### [install logstash] ############################################################################################################
cd $PROJ_DIR
wget https://download.elastic.co/logstash/logstash/logstash-2.2.2.tar.gz
tar xvfz logstash-2.2.2.tar.gz
mkdir $PROJ_DIR/logstash-2.2.2/patterns
mkdir $PROJ_DIR/logstash-2.2.2/log_list
cp $SRC_DIR/logstash/patterns/nginx $PROJ_DIR/logstash-2.2.2/patterns
cp $SRC_DIR/logstash/log_list/nginx.conf $PROJ_DIR/logstash-2.2.2/log_list
cp $SRC_DIR/logstash/log_list/test1_aws.conf $PROJ_DIR/logstash-2.2.2/log_list/test1.conf
cp $SRC_DIR/logstash/log_list/test2_aws.conf $PROJ_DIR/logstash-2.2.2/log_list/test2.conf

sudo -u ubuntu $PROJ_DIR/logstash-2.2.2/bin/logstash -f $PROJ_DIR/logstash-2.2.2/log_list/nginx.conf &
sudo -u ubuntu $PROJ_DIR/logstash-2.2.2/bin/logstash -f $PROJ_DIR/logstash-2.2.2/log_list/test1.conf &
sudo -u ubuntu $PROJ_DIR/logstash-2.2.2/bin/logstash -f $PROJ_DIR/logstash-2.2.2/log_list/test2.conf &

### [install kibana] ############################################################################################################
cd $PROJ_DIR
wget https://download.elastic.co/kibana/kibana/kibana-4.4.1-linux-x64.tar.gz
tar xzvf kibana-4.4.1-linux-x64.tar.gz

chown -Rf ubuntu:ubuntu $PROJ_DIR

echo '' >> $PROJ_DIR/kibana-4.4.1-linux-x64/config/kibana.yml
echo 'elasticsearch.url: "http://$1:9200"' >> $PROJ_DIR/kibana-4.4.1-linux-x64/config/kibana.yml

sudo -u ubuntu $PROJ_DIR/kibana-4.4.1-linux-x64/bin/kibana > /dev/null 2>&1 &
# http://localhost:5601

sudo cp -vp $SRC_DIR/elasticsearch/systemd/system/kibana.service /etc/systemd/system/kibana.service
sudo chmod 664 /etc/systemd/system/kibana.service
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana

### [conf nginx] ############################################################################################################
sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
#http {
#    log_format main '$http_host '
#                    '$remote_addr [$time_local] '
#                    '"$request" $status $body_bytes_sent '
#                    '"$http_referer" "$http_user_agent" '
#                    '$request_time '
#                    '$upstream_response_time';
#    access_log  /var/log/nginx/access.log  main;
#}
sudo nginx -s stop
sudo nginx
# curl http://127.0.0.1:8080

### [make test data] ############################################################################################################
mkdir -p $PROJ_DIR/data
cp $SRC_DIR/data/stats-2017-02-22.log $PROJ_DIR/data

chown -Rf ubuntu:ubuntu $PROJ_DIR

exit 0
