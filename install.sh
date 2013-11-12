#!/bin/bash
echo ""
echo ""
echo "$(tput bold)$(tput setaf 6)CentOS WordPress by GigabyteIO$(tput sgr0)"
echo "Home URL  : http://gigabyte.io"
echo "Github URL: https://github.com/GigabyteIO/CentOS-WordPress"
echo "Author    : Brian Zalewski"
echo ""
echo ""
echo "$(tput bold)$(tput setaf 2)Running preliminary tasks$(tput sgr0)"
echo ""
if [ -f /usr/local/src/gigabyteio/install.sh ];
then
  read -p "$(tput bold)$(tput setaf 3)Warning:$(tput sgr0) The GigabyteIO directory already exists! Delete it and continue the installation? [Y/N] " INSTALL_CHOICE
  case "$INSTALL_CHOICE" in
    y|Y ) echo "" && echo "* $(tput setaf 6)Removing /usr/local/src/gigabyteio$(tput sgr0)" && rm -rf /usr/local/src/gigabyteio;;
    n|N ) exit 1;;
    * ) echo "Invalid input.";;
  esac
fi
echo "* $(tput setaf 6)Installing git$(tput sgr0)"
yum -y --quiet install git
echo "* $(tput setaf 6)Cloning the GigabyteIO git repository to /usr/local/src/gigabyteio$(tput sgr0)"
git clone -q https://github.com/GigabyteIO/WordPress-Droplet.git /usr/local/src/gigabyteio
chmod +x /usr/local/src/gigabyteio/scripts/setup.sh
echo "* $(tput setaf 6)Initializing setup script from /usr/local/src/gigabyteio/scripts/setup.sh$(tput sgr0)"
echo ""
/bin/bash /usr/local/src/gigabyteio/scripts/setup.sh
