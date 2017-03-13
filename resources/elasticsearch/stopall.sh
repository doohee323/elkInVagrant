export PROJ_DIR=/home/vagrant

cd $PROJ_DIR
echo cd $PROJ_DIR

cd node1 && ./stop.sh &
cd $PROJ_DIR
cd node2 && ./stop.sh &
cd $PROJ_DIR
cd node3 && ./stop.sh &

# sudo /bin/kill -9 `ps -ef | grep elasticsearch | grep -v grep | awk '{print $2}'`
# sudo /bin/kill -9 `ps -ef | grep kibana | grep -v grep | awk '{print $2}'`
# sudo /bin/kill -9 `ps -ef | grep logstash | grep -v grep | awk '{print $2}'`
#cd $PROJ_DIR/logstash-1.4.0; bin/logstash -f logstash-mixpanel.conf &

#sudo nginx -s stop

