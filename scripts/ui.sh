#!/usr/bin/env bash

set -x

export PROJ_DIR=/vagrant

###############################################################
# install node, bower, grunt, compass
###############################################################
sudo apt install nodejs-legacy -y
sudo apt install npm -y

sudo npm install -g bower -y
sudo npm install grunt -g
sudo npm install grunt-contrib-jshint -g
sudo apt-get install ruby-compass -y
sudo gem install compass

###############################################################
# sync static resources to target dir
###############################################################
sudo rm -Rf /var/www/html
sudo mkdir -p /var/www/html

cd $PROJ_DIR/tz-angular1.4

npm install
bower install --allow-root
#sudo chown -Rf ubuntu:ubuntu *

#curl http://192.168.82.170

sudo /bin/bash /vagrant/scripts/deploy.sh

###[ adminlte ]###############################################
git clone https://github.com/almasaeed2010/AdminLTE.git
mv AdminLTE /var/www/html/adminlte
chown -Rf www-data:www-data /var/www/html/adminlte

exit 0
