#!/bin/bash
cd ~
yum -y install git expect
git clone https://github.com/MByteIO/CentOS-WordPress.git /usr/local/src/megabyteio
chmod +x /usr/local/src/megabyteio/bash/setup.sh
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
echo "$(tput bold)$(tput setaf 6)Instructions:$(tput sgr0)"
echo ""
echo "1. Edit the file located at /usr/local/src/megabyteio/bash/user-variables.sh with your own information."
echo "2. Run the fully automated installation by entering the following command: /bin/bash /usr/local/src/megabyteio/bash/setup.sh"
