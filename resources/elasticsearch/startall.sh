cd $PROJ_DIR 
cd ./node1 && ./start.sh &
sleep 1
cd $PROJ_DIR
cd ./node2 && ./start.sh &
sleep 1
cd $PROJ_DIR
cd ./node3 && ./start.sh &

#cd $PROJ_DIR/logstash-1.4.0; bin/logstash -f logstash-mixpanel.conf &

#sudo nginx

