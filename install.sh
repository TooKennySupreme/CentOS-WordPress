#!/bin/bash
cd ~
yum -y install git expect
git clone https://github.com/MByteIO/CentOS-WordPress.git /usr/local/src/megabyteio
chmod +x /usr/local/src/megabyteio/bash/setup.sh
echo "Running setup script (bash/setup.sh)."
/bin/bash /usr/local/src/megabyteio/bash/setup.sh
