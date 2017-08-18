#!/usr/bin/env bash

if [ ! -d "tz-spring-boot" ]; then
	echo "git clone https://github.com/doohee323/tz-spring-boot.git"
	git clone https://github.com/doohee323/tz-spring-boot.git
fi

if [ ! -d "tz-angular1.4" ]; then
	echo "run this on this folder!"
	echo "git clone https://github.com/doohee323/tz-angular1.4.git"
	git clone https://github.com/doohee323/tz-angular1.4.git
fi

vagrant destroy -f && vagrant up
vagrant ssh

exit 0
