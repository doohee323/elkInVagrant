#!/bin/bash

export ES=$1

rm -Rf /usr/share/$ES
rm -Rf /var/run/$ES
rm -Rf /var/log/$ES
rm -Rf /var/lib/$ES
rm -Rf /etc/$ES

cp -Rf /usr/share/elasticsearch /usr/share/$ES
cp -Rf /var/run/elasticsearch /var/run/$ES
cp -Rf /var/log/elasticsearch /var/log/$ES
cp -Rf /var/lib/elasticsearch /var/lib/$ES
cp -Rf /etc/elasticsearch /etc/$ES

chown -Rf elasticsearch:elasticsearch /usr/share/$ES
chown -Rf elasticsearch:elasticsearch /var/run/$ES
chown -Rf elasticsearch:elasticsearch /var/log/$ES
chown -Rf elasticsearch:elasticsearch /var/lib/$ES
chown -Rf elasticsearch:elasticsearch /etc/$ES

### [edit elasticsearch config] ############################################################################################################
cp /etc/init.d/elasticsearch /etc/init.d/$ES
sed -i "s/NAME=elasticsearch/NAME=$ES/g" /etc/init.d/$ES
sed -i "s/Provides:          elasticsearch/Provides:          $ES/g" /etc/init.d/$ES

cp /vagrant/resources/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/
sed -i "s/network.bind_host: 0/network.bind_host: 0.0.0.0/g" /etc/$ES/elasticsearch.yml
# for multi instances
sed -i "s/#discovery.zen.ping.unicast.hosts/discovery.zen.ping.unicast.hosts/g" /etc/$ES/elasticsearch.yml
sed -i "s/#discovery.zen.minimum_master_nodes/discovery.zen.minimum_master_nodes/g" /etc/$ES/elasticsearch.yml
sed -i "s/#discovery.zen.ping.multicast.enabled/discovery.zen.ping.multicast.enabled/g" /etc/$ES/elasticsearch.yml

if [ "$ES" = "es2" ];then
	sed -i "s/node-1/node-2/g" /etc/$ES/elasticsearch.yml
	sed -i "s/ 9300/ 9302/g" /etc/$ES/elasticsearch.yml
	sed -i "s/ 9200/ 9202/g" /etc/$ES/elasticsearch.yml
	sed -i "s/node.master/#node.master/g" /etc/$ES/elasticsearch.yml
fi

if [ "$ES" = "es3" ];then
	sed -i "s/node-1/node-3/g" /etc/$ES/elasticsearch.yml
	sed -i "s/ 9300/ 9303/g" /etc/$ES/elasticsearch.yml
	sed -i "s/ 9200/ 9203/g" /etc/$ES/elasticsearch.yml
	sed -i "s/node.master/#node.master/g" /etc/$ES/elasticsearch.yml
fi

