#

# Install requirements
yum -y --quiet install git expect

# Clone the git file
git clone -q https://github.com/MByteIO/CentOS-WordPress.git /usr/local/src/megabyteio
chmod +x /usr/local/src/megabyteio/scripts/setup.sh
echo "* $(tput setaf 6)Initializing setup script from /usr/local/src/megabyteio/scripts/setup.sh$(tput sgr0)"
echo ""
/bin/bash /usr/local/src/megabyteio/scripts/setup.sh
