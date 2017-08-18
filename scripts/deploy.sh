#!/usr/bin/env bash

sudo rsync -avP /vagrant/tz-spring-boot/target/classes/ /opt/tomcat/webapps/ROOT/WEB-INF/classes/ 
sudo rsync -avP /vagrant/tz-spring-boot/target/view/ /opt/tomcat/webapps/ROOT/WEB-INF/view/ 
sudo chown -Rf tomcat:tomcat /opt/tomcat/webapps/ROOT
sudo chmod -Rf 777 /opt/tomcat/webapps/ROOT
sudo chmod -Rf 777 /opt/tomcat/logs

sudo rsync -avP /vagrant/tz-angular1.4/app/ /var/www/html/ 
sudo sed -i "s/localhost:8080/dev.tz.com/g" /var/www/html/scripts/app.js

sudo cp -Rf /vagrant/tz-angular1.4/bower_components/ /var/www/html/bower_components/
sudo cp -rf /vagrant/resources/nginx/default /etc/nginx/sites-available/default
sudo cp -rf /vagrant/resources/nginx/nginx.conf /etc/nginx/nginx.conf

sudo chown -Rf www-data:www-data /var/www/html
sudo chmod -Rf 777 /var/www/html

exit 0
