#!/bin/bash
echo ""
echo "$(tput bold)$(tput setaf 6)Installing GigabyteIO for WordPress...$(tput sgr0)"
echo "Github URL: https://github.com/GigabyteIO/WordPress-Droplet"
echo "GigabyteIO URL: http://gigabyte.io/"
echo ""
if [ -f /usr/local/src/gigabyteio/install.sh ];
then
  read -p "$(tput bold)$(tput setaf 3)Warning:$(tput sgr0) The GigabyteIO directory already exists! Delete it and continue the installation? [Y/N] " INSTALL_CHOICE
  case "$INSTALL_CHOICE" in
    y|Y ) echo "$(tput setaf 5)* Removing /usr/local/src/gigabyteio(tput sgr0)" && rm -rf /usr/local/src/gigabyteio;;
    n|N ) exit 1;;
    * ) echo "Invalid input.";;
  esac
fi

echo "$(tput setaf 6)* Installing git$(tput sgr0)"
yum --quiet install git
echo "$(tput setaf 2)* Cloning the GigabyteIO git repository to /usr/local/src/gigabyteio$(tput sgr0)"
git clone -q https://github.com/GigabyteIO/WordPress-Droplet.git /usr/local/src/gigabyteio
chmod +x /usr/local/src/gigabyteio/scripts/setup.sh
echo "$(tput setaf 2)* Initializing setup script from /usr/local/src/gigabyteio/scripts/setup.sh$(tput sgr0)"
/bin/bash /usr/local/src/gigabyteio/scripts/setup.sh
