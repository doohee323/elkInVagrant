#!/usr/bin/env bash

set -x

export USER=vagrant  # for vagrant
export PROJ_NAME=tz-spring-boot
export HOME_DIR=/home/$USER
export PROJ_DIR=/vagrant
export SRC_DIR=/vagrant/resources  # for vagrant

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PROJ_NAME=tz-spring-boot' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PROJ_DIR=/vagrant' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR=$HOME_DIR' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR=$SRC_DIR' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'alias build=\"/bin/bash $PROJ_DIR/scripts/build.sh;\"' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'alias deploy=\"/bin/bash $PROJ_DIR/scripts/deploy.sh;\"' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'alias log=\"tail -f /opt/tomcat/logs/catalina.out;\"' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'alias web=\"sudo nginx -s stop;sleep 2;sudo nginx;\"' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'alias was=\"sudo systemctl restart tomcat;\"' >> $HOME_DIR/.bashrc"

source $HOME_DIR/.bashrc

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install git -y
sudo apt-get install autoconf -y

###############################################################
# install java 8
###############################################################
# for ubuntu 14.04
# sudo apt-get install python-software-properties debconf-utils -y
sudo apt-get install debconf-utils -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:webupd8team/java -y 
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo apt-get install oracle-java8-set-default

###############################################################
# git cache
###############################################################
#sudo apt-get install libgnome-keyring-dev -y
#sudo mkdir -p /usr/share/doc/git/contrib/credential
#sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring
#git config --global credential.helper /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
#sudo make --directory=/usr/share/gtk-doc/html/gnome-keyring

###############################################################
# install maven
###############################################################
sudo apt install maven -y;

###############################################################
# install nginx
###############################################################
sudo apt-get install nginx -y

sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp -Rf $SRC_DIR/nginx/default /etc/nginx/sites-enabled
# curl http://127.0.0.1:80
sudo service nginx stop

###############################################################
# install tomcat
###############################################################
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

cd /tmp
sudo wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz 
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

###############################################################
# register tomcat service
###############################################################

sudo apt-get install systemd-services -y
sudo cp -vp /vagrant/resources/tomcat/systemd/system/tomcat.service /etc/systemd/system/tomcat.service
sudo chmod 664 /etc/systemd/system/tomcat.service

sudo systemctl daemon-reload
sudo systemctl enable tomcat

# for remote debugging
sudo sed -i "s/exec /#exec /g" /opt/tomcat/bin/startup.sh
sudo sh -c "echo 'exec \"\$PRGDIR\"/\"\$EXECUTABLE\" jpda start \"\$@\"' >> /opt/tomcat/bin/startup.sh"

###############################################################
# open firewalls
###############################################################
sudo ufw allow "Nginx Full"
sudo ufw allow 8080
sudo ufw allow 8000

sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo service iptables save
sudo service iptables restart


#sudo apt-get install -y iptables-persistent
#sudo netfilter-persistent save
#sudo netfilter-persistent reload

###############################################################
# install tz-angular1.4
###############################################################

if [ ! -d "$PROJ_DIR/$PROJ_NAME" ]; then
	git config --global credential.helper cache 'cache --timeout 360000'
	#git clone https://github.com/doohee323/tz-spring-boot.git
	cd $PROJ_NAME
else
	cd $PROJ_NAME
	#git pull origin master
fi

sudo mkdir -p $PROJ_DIR/$PROJ_NAME
#sudo userdel www-data
#sudo useradd -c "www-data" -m -d $PROJ_DIR/$PROJ_NAME/ -s /bin/bash -G sudo www-data
sudo usermod -a -G www-data www-data
sudo usermod --home $PROJ_DIR/$PROJ_NAME/ www-data
echo -e "www-data\nwww-data" | sudo passwd www-data

sudo chown -R www-data:www-data /var/www/html/

###############################################################
# call ui script
###############################################################

bash /vagrant/scripts/mysql.sh
bash /vagrant/scripts/server.sh
bash /vagrant/scripts/ui.sh

#cat <(crontab -l) <(echo "* * * * * sudo /bin/bash $PROJ_DIR/scripts/deploy.sh") | crontab -

###############################################################
# start services
###############################################################

sudo service nginx stop
sudo service nginx start

#cd $PROJ_DIR/$PROJ_NAME
#nohup java -jar ROOT.jar --server.port=8080 &
#su - vagrant -c "nohup mvn spring-boot:run &" 

# start tomcat
sudo systemctl start tomcat
#sudo systemctl stop tomcat
#sudo systemctl status tomcat

# first build
su - vagrant -c "/bin/bash /vagrant/scripts/build.sh"

#curl http://192.168.82.170:8080

exit 0
