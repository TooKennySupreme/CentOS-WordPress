#!/bin/bash

yum -y --exclude=kernel* update
yum -y install git bc
git clone https://github.com/GigabyteIO/WordPress-Droplet.git /usr/local/src/gigabyteio
chmod +x /usr/local/src/gigabyteio/scripts/setup
/bin/bash /usr/local/src/gigabyteio/scripts/setup
