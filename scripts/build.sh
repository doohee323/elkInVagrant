#!/usr/bin/env bash

set -x

export PROJ_DIR=/vagrant

sudo chown -Rf tomcat:tomcat /opt/tomcat
sudo chmod -Rf 777 /opt/tomcat/webapps
sudo chmod -Rf 777 /opt/tomcat/logs

###############################################################
# sync static resources to target dir
###############################################################
cd $PROJ_DIR/tz-spring-boot
sudo -u vagrant mvn -f pom.xml clean compile package -Dmaven.test.skip=true

sudo rm -Rf /opt/tomcat/webapps/ROOT/
sudo cp $PROJ_DIR/tz-spring-boot/target/tz-1.0.0-SNAPSHOT.war /opt/tomcat/webapps/ROOT.war

exit 0
