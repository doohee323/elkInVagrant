#!/bin/bash

export ES_HEAP_SIZE=256m
export ES_HEAP_NEWSIZE=128m
export JAVA_OPT="-server -XX:+AggressiveOpts -XX:UseCompressedOops -XX:MaxDirectMemorySize -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseC MSInitiatingOccupancyOnly"
ES=$PROJ_DIR/node1
$ES/bin/elasticsearch -Des.pidfile=$ES/bin/es1.pid -Djava.net.preferIPv4Stack=true -Des.max-open-files=true > /dev/null 2>&1 &

