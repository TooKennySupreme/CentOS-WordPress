#!/bin/bash -x

# Setting time zone has to be done manually for now - not exactly sure how to find and replace with a variable - if anyone could guide me in the right direction, I'll add this feature :)
# Declare script variables for future portability
echo "* $(tput setaf 6)Declaring potentially customizable script variables in setup.sh$(tput sgr0)"
CENTMIN_DIR='usr/local/src' # Directory where centmin is installed
INSTALL_FOLDER_NAME='gigabyteio' # Folder name for the scripts, stored next to the centminmod directory in CENTMINDIR
CONF_FOLDER='configs' # Name of folder in the GigabyteIO directory that holds the configuration files
SCRIPTS_FOLDER='scripts' # Name of folder in the GigabyteIO directory that holds scripts
WORDPRESS_FOLDER='wordpress' # Name of folder in the GigabyteIO directory that holds WordPress related files
SSH_PORT_NUMBER=8388 # SSH port used, this is changed automatically after the Centmin install finishes
CENTMIN_FOLDER_NAME='centmin-v1.2.3mod' # Name of centmin folder
CENTMIN_DOWNLOAD_URL='http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip' # Centmin download URL
CENTMIN_FILE_NAME='centmin-v1.2.3-eva2000.04.zip' # Centmin zip file name
GITHUB_URL='https://github.com/GigabyteIO/WordPress-Droplet.git' # GigabyteIO git repo
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains' # Path to website files folder
NGINX_CONF_DIR='usr/local/nginx/conf' # Path to nginx configurations

echo ""
echo "$(tput bold)$(tput setaf 2)Step 2 of 7:$(tput sgr0) Update system"
echo ""
echo "* $(tput setaf 6)Performing a system update (excluding kernel)$(tput sgr0)"
yum -y --quiet --exclude=kernel* update
echo "* $(tput setaf 6)Installing some dependencies (bc expect)$(tput sgr0)"
yum -y --quiet install bc expect
# Change root user password
#http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
echo ""
echo "$(tput bold)$(tput setaf 2)Step 3 of 7:$(tput sgr0) Set up administrator account"
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) Begin by changing the root password. After the installation, there will be no reason to use the root user. We will instead execute root commands using a different user account with root privileges. You should make this root password long and very hard to guess."
echo ""
passwd
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) Now create a new user and password combination. This is the user that you will use when doing anything that requires root privileges. When doing something that requires root privileges with this new user, you will have to add 'sudo' to the beginning of the command."
echo ""
# Set up new root username and password for security purposes
if [ $(id -u) -eq 0 ]; then
        read -p "Enter a new root username: " NEW_ROOT_USERNAME
        read -s -p "Enter the new root users password: " NEW_ROOT_PASSWORD
        egrep "^$NEW_ROOT_USERNAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo -e "\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) $NEW_ROOT_USERNAME already exists! Aborting installation."
                exit 1
        else
                ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
                useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
                [ $? -eq 0 ] && echo -e "\n* $(tput setaf 6)$NEW_ROOT_USERNAME added to user list$(tput sgr0)" || echo -e "\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) Failed to add $NEW_ROOT_USERNAME to the user list"
        fi
else
        echo -e "\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) You must be root to add a user to the system. Aborting installation."
        exit 2
fi
# Add new root user to visudo list
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
chmod +x visudo.sh
echo "* $(tput setaf 6)Giving root permissions to $NEW_ROOT_USER_NAME$(tput sgr0)"
./visudo.sh $NEW_ROOT_USERNAME
chmod 644 visudo.sh
echo ""
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) It is highly recommended to log into your server with an SSH key. This will encrypt all data communications (preventing clear text passwords), make it much harder for hackers to target you, and allow you to login to your server without typing your username ($NEW_ROOT_USERNAME). With Digital Ocean, you can create a server with an SSH key system already implemented. By answering yes to the following prompt, password authentication will be disabled and it will only be possible to log in to your server with an SSH key. The login credentials will also be transferred from the root user to the new root user we just created ($NEW_ROOT_USERNAME)."
echo ""
# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key? [Y/N] " SSH_CHOICE
case "$SSH_CHOICE" in
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "Invalid input.";;
esac

# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
        echo "* $(tput setaf 6)Copying root SSH key to $NEW_ROOT_USER_NAME's SSH key file$(tput sgr0)"
        cp /root/.ssh/authorized_keys /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
        echo "* $(tput setaf 6)Removing root SSH key file$(tput sgr0)"
        rm ~/.ssh/authorized_keys
        echo "* $(tput setaf 6)Applying appropriate permissions to $NEW_ROOT_USERNAME's SSH key file and directory$(tput sgr0)"
        chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh
        chmod 700 /home/$NEW_ROOT_USERNAME/.ssh
        chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
        chmod 600 /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
fi

# Tweak SSH settings for security
# Let CentminMod handle the changing of the port number so that there are no conflicts with the firewall
# perl -pi -e 's/#Port 22/Port $SSH_PORT_NUMBER/g' /etc/ssh/sshd_config
echo "* $(tput setaf 6)Forcing SSH to only accept connections to server's IP address$(tput sgr0)"
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
echo "* $(tput setaf 6)Disabling SSH login ability for the root user$(tput sgr0)"
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "* $(tput setaf 6)Allowing only $NEW_ROOT_USERNAME to log in via SSH$(tput sgr0)"
echo "AllowUsers $NEW_ROOT_USERNAME" >> /etc/ssh/sshd_config

# Modifies sshd_config if an SSH key is being used instead of a password
if [ "$SSH_CHOICE" == "yes" ]; then
        echo "* $(tput setaf 6)Disabling ability to login to SSH via password authentication$(tput sgr0)"
        perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        # This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
        echo "* $(tput setaf 6)Increasing the ServerKeyBits to 2048$(tput sgr0)"
        perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
fi
echo "$(tput bold)$(tput setaf 2)Step 4 of 7:$(tput sgr0) Configure and install CentminMod"
# Download and set up CentminMod directory
cd /$CENTMIN_DIR
echo "* $(tput setaf 6)Downloading CentminMod from $CENTMIN_DOWNLOAD_URL$(tput sgr0)"
wget -q $CENTMIN_DOWNLOAD_URL
echo "* $(tput setaf 6)Unzipping $CENTMIN_FILE_NAME to $CENTMIN_DIR$(tput sgr0)"
unzip -q $CENTMIN_FILE_NAME
echo "* $(tput setaf 6)Removing $CENTMIN_FILE_NAME$(tput sgr0)"
rm $CENTMIN_FILE_NAME
cd $CENTMIN_FOLDER_NAME

# Change time zone in centmin.sh
echo "* $(tput setaf 6)Changing time zone to America/New_York in centmin.sh"
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change custom TCP packet header in centmin.sh
echo "* $(tput setaf 6)Changing TCP packet header to GigabyteIO in centmin.sh$(tput sgr0)"
perl -pi -e 's/nginx centminmod/GigabyteIO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change permissions of centmin.sh to executable
echo "* $(tput setaf 6)Giving centmin.sh executable permissions$(tput sgr0)"
chmod +x centmin.sh

echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) The initial set up is complete. If you restart the server or attempt to log in via SSH, you will only be able to connect via the server's IP address on port number $SSH_PORT_NUMBER (please note that the port number is changed at the end of the installation so if the script fails for whatever reason, the SSH port might still be 22). In addition, the only user that can login is your new root username ($NEW_ROOT_USERNAME). If for some reason you need to use the root user, you will have to login with your new root username ($NEW_ROOT_USERNAME) and then switch to the root user by entering 'su'.\n\nThe script will now compile the server via CentminMod. This process generally takes around 30 minutes. For the most part, it is an unattended installation."
echo ""
read -p "$(tput bold)Press any key to continue... $(tput sgr0)" -n1 -s

# Install CentminMod
#expect \"New password for the MySQL \"root\" user:\"
#send \"ls\r\"
CENTMIN_INSTALL_EXPECT=$(expect -c "
spawn bash centmin.sh
expect \"Enter option [ 1 - 21 ]\"
send \"1\r\"
expect "New password for the MySQL \"root\" user:"
send "PasswordHere\r"
expect "Repeat password for the MySQL \"root\" user:"
send "PasswordHere\r"
expect eof
")
echo "$CENTMIN_INSTALL_EXPECT"


#cp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup
#perl -pi -e 's/read -ep "Enter existing SSH port number \(default = 22 for fresh installs\): " EXISTPORTNUM/EXISTPORTNUM=22/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#perl -pi -e 's/read -ep "Enter the SSH port number you want to change to: " PORTNUM/PORTNUM=${SSH_PORT_NUMBER}/g' sshd.inc
#./centmin.sh sshdport
# Restore centmin SSH config file to original state
#rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#cp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
#rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup

# Restore centmin.sh menu system (to keep centmin.sh in original condition
# NOTE: Substitute (find and replace) "foo" with "bar" on lines that match "baz"
# NOTE: perl -pe '/baz/ && s/foo/bar/'
# NOTE: See http://www.catonmat.net/download/perl1line.txt for more tricks
#perl -pi -e '/ENABLE_MENU=.n./ && s/n/y/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change permissions of centmin.sh back to original
echo "* $(tput setaf 6)Restoring centmin.sh permissions to original state$(tput sgr0)"
chmod 644 /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Move/replace nginx configuration files
echo "* $(tput setaf 6)Copying nginx configuration files from /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER to /$NGINX_CONF_DIR$(tput sgr0)"
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/cloudflare.conf /$NGINX_CONF_DIR/cloudflare.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/nginx.conf /$NGINX_CONF_DIR/nginx.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/phpwpcache.conf /$NGINX_CONF_DIR/phpwpcache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/roots.conf /$NGINX_CONF_DIR/roots.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/wp_fastcgicache.conf /$NGINX_CONF_DIR/wp_fastcgicache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/wpcache.conf /$NGINX_CONF_DIR/wpcache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/wpnocache.conf /$NGINX_CONF_DIR/wpnocache.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/wpsecure.conf /$NGINX_CONF_DIR/wpsecure.conf
cp -f /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$CONF_FOLDER/yoast.conf /$NGINX_CONF_DIR/yoast.conf

# Run scripts
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
echo "* $(tput setaf 6)Granting executable permissions to memory.sh, tweaks.sh, and whitelist.sh$(tput sgr0)"
chmod +x memory.sh
chmod +x tweaks.sh
chmod +x whitelist.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/memory.sh$(tput sgr0)"
./memory.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/tweaks.sh$(tput sgr0)"
./tweaks.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/whitelist.sh$(tput sgr0)"
./whitelist.sh
echo "* $(tput setaf 6)Restoring memory.sh, tweaks,sh, and whitelist.sh permissions to original state$(tput sgr0)"
chmod 644 memory.sh
chmod 644 tweaks.sh
chmod 644 whitelist.sh
echo ""
echo ""
echo "$(tput bold)$(tput setaf 6)Thanks for using CentOS WordPress by GigabyteIO$(tput sgr0)"
echo "Home URL  : http://gigabyte.io"
echo "Github URL: https://github.com/GigabyteIO/CentOS-WordPress"
