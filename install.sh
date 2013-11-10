#!/bin/bash

yum -y --exclude=kernel* update
yum -y install git bc
git clone https://github.com/MegabyteIO/WP-Droplet.git /usr/local/src/megabyteio
chmod +x /usr/local/src/megabyteio/scripts/setup
/bin/bash /usr/local/src/megabyteio/scripts/setup
