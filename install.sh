#!/bin/bash

yum -q -y --exclude=kernel* update
yum -q -y install git bc expect
git clone https://github.com/GigabyteIO/WordPress-Droplet.git /usr/local/src/gigabyteio
chmod +x /usr/local/src/gigabyteio/scripts/setup.sh
/bin/bash /usr/local/src/gigabyteio/scripts/setup.sh
