cd ./node1;./stop.sh &
cd ../node2;./stop.sh &
cd ../node3;./stop.sh &

#cd $PROJ_DIR/logstash-1.4.0; bin/logstash -f logstash-mixpanel.conf &

sudo nginx -s stop

