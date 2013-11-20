#!/bin/bash
echo ""
echo ""
echo "$(tput bold)$(tput setaf 6)CentOS WordPress$(tput sgr0)"
echo "Home URL  : http://megabyte.io"
echo "Github URL: https://github.com/MByteIO/CentOS-WordPress"
echo "Author    : Brian Zalewski"
echo ""
echo "Credit to CentminMod! Check out their website at http://centminmod.com!"
echo ""
echo ""
echo "$(tput bold)$(tput setaf 2)Running preliminary tasks$(tput sgr0)"
echo ""
echo "* $(tput setaf 6)Changing directory to current users home directory$(tput sgr0)"
cd ~
if [ -f /usr/local/src/megabyteio/install.sh ];
then
  echo ""
  read -p "$(tput bold)$(tput setaf 3)Warning:$(tput sgr0) The MegabyteIO directory already exists! Delete it and continue the installation? [Y/N] " INSTALL_CHOICE
  case "$INSTALL_CHOICE" in
    y|Y ) echo "" && echo "* $(tput setaf 6)Removing /usr/local/src/megabyteio$(tput sgr0)" && rm -rf /usr/local/src/megabyteio;;
    n|N ) echo "$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) Installation aborted by user." && exit;;
    * ) echo "$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) Invalid input." && exit;;
  esac
fi
echo "* $(tput setaf 6)Installing git$(tput sgr0)"
yum -y --quiet install git
echo "* $(tput setaf 6)Cloning the MegabyteIO git repository to /usr/local/src/megabyteio$(tput sgr0)"
git clone -q https://github.com/MByteIO/CentOS-WordPress.git /usr/local/src/megabyteio
chmod +x /usr/local/src/megabyteio/scripts/setup.sh
echo "* $(tput setaf 6)Initializing setup script from /usr/local/src/megabyteio/scripts/setup.sh$(tput sgr0)"
echo ""
/bin/bash /usr/local/src/megabyteio/scripts/setup.sh
