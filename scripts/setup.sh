#!/bin/sh

# Move timezone to variables up here
# Directory where centmin is installed
CENTMIN_DIR="usr/local/src"
# Folder name for the scripts, stored next to the centminmod directory in CENTMINDIR
INSTALL_FOLDER_NAME="MegabyteIO"
# Following folders are names of folders in PoorIO directory
CONF_FOLDER="configs" # Configuration files
SCRIPTS_FOLDER="scripts" # Shell scripts
WORDPRESS_FOLDER="wordpress" # WordPress supplements
SSH_PORT_NUMBER=8388
CENTMIN_FOLDER_NAME="centmin-v1.2.3mod"
CENTMIN_DOWNLOAD_URL="http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip"
CENTMIN_FILE_NAME="centmin-v1.2.3-eva2000.04.zip"
GITHUB_URL="https://github.com/MegabyteIO/WP-Droplet.git"
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'
NGINX_CONF_DIR='usr/local/nginx/conf'
# Change root user password
passwd

# Set up new root username and password
if [ $(id -u) -eq 0 ]; then
        read -p "Enter a new root username: " NEW_ROOT_USERNAME
        read -s -p "Enter the new root users password: " NEW_ROOT_PASSWORD
        egrep "^$NEW_ROOT_USERNAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$NEW_ROOT_USERNAME already exists!"
                exit 1
        else
                ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
                useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
                [ $? -eq 0 ] && echo "$NEW_ROOT_USERNAME has been added to the user list." || echo "Failed to add $NEW_ROOT_USERNAME to the user list."
        fi
else
        echo "You must be root to add a user to the system."
        exit 2
fi

# Add new root user to visudo list
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
chmod +x visudo
./visudo.sh $NEW_ROOT_USERNAME
chmod 644 visudo

# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key (y/n)? " SSH_CHOICE
case "$SSH_CHOICE" in
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "Invalid input.";;
esac

# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
echo "Moving SSH key credentials from root user to new root user. The root user will no longer be able to connect via SSH."
  cp /root/.ssh/authorized_keys /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
  rm ~/.ssh/authorized_keys
  chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh
  chmod 700 /home/$NEW_ROOT_USERNAME/.ssh
  chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
  chmod 600 /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
fi

# Tweak SSH settings for security
# Let CentminMod handle the changing of the port number so that there are no conflicts with the firewall
# perl -pi -e 's/#Port 22/Port $SSH_PORT_NUMBER/g' /etc/ssh/sshd_config
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers $NEW_ROOT_USERNAME" >> /etc/ssh/sshd_config

# Settings for SSH key login
if [ "$SSH_CHOICE" == "yes" ]; then
perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  # This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
  perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
fi

# Download and set up CentminMod
cd /$CENTMIN_DIR
wget $CENTMIN_DOWNLOAD_URL
unzip $CENTMIN_FILE_NAME
rm -f $CENTMIN_FILE_NAME
cd $CENTMIN_FOLDER_NAME

# Change time zone
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/nginx centminmod/Powered by Poor.IO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
chmod +x centmin.sh

# Change SSH port
perl -pi -e 's/read -ep "Enter option \[ 1 - 21 ] " option/option=sshdport\n perl -pi -e 's/option=sshdport/read -ep "Enter option \[ 1 - 21 ] " option/gm' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
#perl -pi -e 's/read -ep "Enter existing SSH port number \(default = 22 for fresh installs\): " EXISTPORTNUM/EXISTPORTNUM=22/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#perl -pi -e 's/read -ep "Enter the SSH port number you want to change to: " PORTNUM/PORTNUM=$SSH_PORT_NUMBER/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#./centmin.sh


# Restore files to original format
#perl -pi -e 's/PearlPlaceHolder/perl -pi -e \'s/option=sshdport/read -ep "Enter option [ 1 - 21 ] " option/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
#perl -pi -e 's/EXISTPORTNUM=22/#EXISTPORTNUM=22/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#perl -pi -e 's/PORTNUM=$SSH_PORT_NUMBER/#EXISTPORTNUM=22/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc

# Run a fresh Centmin install
#perl -pi -e 's/read -ep "Enter option \[ 1 - 21 ] " option/option=install/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
#./centmin.sh
# Restore Centmin files to original format
#perl -pi -e 's/option=install/read -ep "Enter option [ 1 - 21 ] " option/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Whitelist Cloudflare IPs
csf -a 204.93.240.0/24 Cloudflare
csf -a 204.93.177.0/24 Cloudflare
csf -a 199.27.128.0/21 Cloudflare
csf -a 173.245.48.0/20 Cloudflare
csf -a 103.21.244.0/22 Cloudflare
csf -a 103.22.200.0/22 Cloudflare
csf -a 103.31.4.0/22 Cloudflare
csf -a 141.101.64.0/18 Cloudflare
csf -a 108.162.192.0/18 Cloudflare
csf -a 190.93.240.0/20 Cloudflare
csf -a 188.114.96.0/20 Cloudflare
csf -a 197.234.240.0/22 Cloudflare
csf -a 198.41.128.0/17 Cloudflare
csf -a 162.158.0.0/15 Cloudflare

# Tweak settings
perl -pi -e 's/apc.shm_size=32M/apc.shm_size=256M/g' /root/centminmod/php.d/apc.ini
perl -pi -e 's/apc.enable_cli=1/apc.enable_cli=0/g' /root/centminmod/php.d/apc.ini
echo "apc.enable_cli = Off" >> /usr/local/lib/php.ini

# Move configs
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/cloudflare.conf /$NGINX_CONF_DIR/cloudflare.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/nginx.conf /$NGINX_CONF_DIR/nginx.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/phpwpcache.conf /$NGINX_CONF_DIR/phpwpcache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/roots.conf /$NGINX_CONF_DIR/roots.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/wp_fastcgicache.conf /$NGINX_CONF_DIR/wp_fastcgicache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/wpcache.conf /$NGINX_CONF_DIR/wpcache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/wpnocache.conf /$NGINX_CONF_DIR/wpnocache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/wpsecure.conf /$NGINX_CONF_DIR/wpsecure.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/configs/yoast.conf /$NGINX_CONF_DIR/yoast.conf
