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

### [isntall es xpack] ############################################################################################################
cd /usr/share/elasticsearch/bin
#./elasticsearch-plugin remove x-pack
./elasticsearch-plugin install --b x-pack
cp -rf /usr/share/elasticsearch/bin/x-pack /usr/share/es1/bin
#cp -rf /usr/share/elasticsearch/bin/x-pack /usr/share/es2/bin

### [isntall logstash xpack] ############################################################################################################
cd /usr/share/logstash/bin
./logstash-plugin install x-pack
cp $SRC_DIR/logstash/logstash_xp.yml /etc/logstash/logstash.yml

cp $SRC_DIR/logstash/log_list/nginx_xp.conf /etc/logstash/conf.d/nginx.conf
cp $SRC_DIR/logstash/log_list/test_xp.conf /etc/logstash/conf.d/test.conf

### [add user & role for xpack] ############################################################################################################
bash $SRC_DIR/elasticsearch/queries/add_user_role.sh

### [install kibana xpack] ############################################################################################################
cd /usr/share/kibana/bin
./kibana-plugin install x-pack
update-rc.d kibana defaults 96 9
cp -R $SRC_DIR/kibana/kibana_xp.yml /etc/kibana/kibana.yml

### [service restart] ############################################################################################################
service es1 restart
#service es2 restart
service kibana restart
systemctl restart logstash_nginx

exit 0
