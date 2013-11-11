#!/bin/bash
echo "$(tput bold)$(tput setaf 6)Installing GigabyteIO...$(tput sgr0)"
echo ""
if [ -f /usr/local/src/gigabyteio/install.sh ];
then
  read -p "The GigabyteIO directory already exists! Do you want to delete it and continue the installation? (y/n)" INSTALL_CHOICE
  case "$INSTALL_CHOICE" in
    y|Y ) rm -rf /usr/local/src/gigabyteio;;
    n|N ) exit 1;;
    * ) echo "Invalid input.";;
  esac
fi

echo "* Installing git"
yum -y --quiet install git
echo "* Cloning the GigabyteIO git repository to /usr/local/src/gigabyteio"
git clone -q https://github.com/GigabyteIO/WordPress-Droplet.git /usr/local/src/gigabyteio
chmod +x /usr/local/src/gigabyteio/scripts/setup.sh
echo "* Initializing setup script from /usr/local/src/gigabyteio/scripts/setup.sh"
/bin/bash /usr/local/src/gigabyteio/scripts/setup.sh
