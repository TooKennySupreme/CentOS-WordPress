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
yum -y --quiet --exclude=kernel* --exclude=setup* update
echo "* $(tput setaf 6)Installing some dependencies (bc and expect)$(tput sgr0)"
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
                echo -e "\n\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) $NEW_ROOT_USERNAME already exists! Aborting installation."
                exit 1
        else
                ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
                useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
                [ $? -eq 0 ] && echo -e "\n\n* $(tput setaf 6)$NEW_ROOT_USERNAME added to user list$(tput sgr0)" || echo -e "\n\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) Failed to add $NEW_ROOT_USERNAME to the user list"
        fi
else
        echo -e "\n\n$(tput setaf 1)$(tput bold)ERROR:$(tput sgr0) You must be the root user. Aborting installation."
        exit 2
fi
# Add new root user to visudo list
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER$(tput sgr0)"
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
echo "* $(tput setaf 6)Granting executable permissions to visudo.sh$(tput sgr0)"
chmod +x visudo.sh
echo "* $(tput setaf 6)Giving root permissions to $NEW_ROOT_USERNAME using visudo.sh$(tput sgr0)"
./visudo.sh $NEW_ROOT_USERNAME
echo "* $(tput setaf 6)Restoring visudo.sh permissions to original state$(tput sgr0)"
chmod 644 visudo.sh
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) It is highly recommended to log into your server with an SSH key. This will encrypt all data communications (preventing clear text passwords), make it much harder for hackers to target you, and allow you to login to your server without typing your username ($NEW_ROOT_USERNAME). With Digital Ocean, you can create a server with an SSH key system already implemented. By answering yes to the following prompt, password authentication will be disabled and it will only be possible to log in to your server with an SSH key. The login credentials will also be transferred from the root user to the new root user we just created ($NEW_ROOT_USERNAME)."
echo ""
# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key? [Y/N] " SSH_CHOICE
case "$SSH_CHOICE" in
  y|Y ) SSH_CHOICE=yes;;
  n|N ) SSH_CHOICE=no;;
  * ) echo "Invalid input.";;
esac
echo ""
# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
        echo "* $(tput setaf 6)Copying root SSH key to $NEW_ROOT_USER_NAME's SSH key file$(tput sgr0)"
        cp /root/.ssh/authorized_keys /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
        echo "* $(tput setaf 6)Removing root SSH key file$(tput sgr0)"
        rm ~/.ssh/authorized_keys
        echo "* $(tput setaf 6)Applying appropriate permissions and ownership to $NEW_ROOT_USERNAME's SSH key file and directory$(tput sgr0)"
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
echo ""
echo "$(tput bold)$(tput setaf 2)Step 4 of 7:$(tput sgr0) Configure and install CentminMod"
echo ""
# Download and set up CentminMod directory
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR$(tput sgr0)"
cd /$CENTMIN_DIR
echo "* $(tput setaf 6)Downloading CentminMod from $CENTMIN_DOWNLOAD_URL$(tput sgr0)"
wget -q $CENTMIN_DOWNLOAD_URL
echo "* $(tput setaf 6)Unzipping $CENTMIN_FILE_NAME to $CENTMIN_DIR$(tput sgr0)"
unzip -q $CENTMIN_FILE_NAME
echo "* $(tput setaf 6)Removing $CENTMIN_FILE_NAME$(tput sgr0)"
rm $CENTMIN_FILE_NAME
echo "* $(tput setaf 6)Changing directory to $CENTMIN_FOLDER_NAME$(tput sgr0)"
cd $CENTMIN_FOLDER_NAME

# Change time zone in centmin.sh
echo "* $(tput setaf 6)Changing time zone to America/New_York in centmin.sh"
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change custom TCP packet header in centmin.sh
echo "* $(tput setaf 6)Changing TCP packet header to GigabyteIO in centmin.sh$(tput sgr0)"
perl -pi -e 's/nginx centminmod/GigabyteIO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) The initial set up is complete. The script will now compile the server via CentminMod. This process generally takes around 30 minutes. The installation will be run with the following variables (you should probably write these down):"
echo ""
echo "$(tput bold)$(tput setaf 3)MySQL root password:$(tput sgr0) Your Root Password"
echo "$(tput bold)$(tput setaf 3)Memcached Monitor Username:$(tput sgr0) GigabyteIO"
MEMCACHED_PWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c16 | tr -d '-')
echo "$(tput bold)$(tput setaf 3)Memcached Monitor Password:$(tput sgr0) $MEMCACHED_PWORD"
echo ""
read -p "$(tput bold)Press any key to continue and install CentminMod... $(tput sgr0)" -n1 -s
echo ""
# Install CentminMod with expect script to automate user inputs
echo "* $(tput setaf 6)Copying centmin-install.exp from /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cp /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/centmin-install.exp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-install.exp
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME
echo "* $(tput setaf 6)Giving centmin-install.exp executable permissions$(tput sgr0)"
chmod +x centmin-install.exp
# Change permissions of centmin.sh to executable
echo "* $(tput setaf 6)Giving centmin.sh executable permissions$(tput sgr0)"
chmod +x centmin.sh
echo "* $(tput setaf 6)Initializing the CentminMod install process via centmin-install.exp$(tput sgr0)"
./centmin-install.exp
#expect "New password for the MySQL \"root\" user:"
#send "PasswordHere\r"
#expect "Repeat password for the MySQL \"root\" user:"
#send "PasswordHere\r"
#Remove anonymous users? [Y/n]
# y
# Disallow root login remotely? [Y/n]
#Remove test database and access to it? [Y/n]
#Reload privilege tables now? [Y/n]
#(Type username your want to set and press Enter):
#(Type password your want to set and press Enter):

# Change permissions of centmin.sh and centmin-install.exp back to original
echo "* $(tput setaf 6)Removing centmin-install.exp from CentminMod folder$(tput sgr0)"
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-install.exp
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
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER$(tput sgr0)"
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
echo "* $(tput setaf 6)Granting executable permissions to memory.sh$(tput sgr0)"
chmod +x memory.sh
echo "* $(tput setaf 6)Granting executable permissions to tweaks.sh$(tput sgr0)"
chmod +x tweaks.sh
echo "* $(tput setaf 6)Granting executable permissions to whitelist.sh$(tput sgr0)"
chmod +x whitelist.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/memory.sh$(tput sgr0)"
./memory.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/tweaks.sh$(tput sgr0)"
./tweaks.sh
echo "* $(tput setaf 6)Running /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/whitelist.sh$(tput sgr0)"
./whitelist.sh
echo "* $(tput setaf 6)Restoring memory.sh permissions to original state$(tput sgr0)"
chmod 644 memory.sh
echo "* $(tput setaf 6)Restoring tweaks.sh permissions to original state$(tput sgr0)"
chmod 644 tweaks.sh
echo "* $(tput setaf 6)Restoring whitelist.sh permissions to original state$(tput sgr0)"
chmod 644 whitelist.sh
echo ""
echo ""
echo "$(tput bold)$(tput setaf 2)Installation Complete$(tput sgr0)"
echo ""
echo "$(tput bold)$(tput setaf 6)Thanks for choosing CentOS WordPress by GigabyteIO$(tput sgr0)"
echo "Home URL  : http://gigabyte.io"
echo "Github URL: https://github.com/GigabyteIO/CentOS-WordPress"
echo "Author    : Brian Zalewski"
echo ""
echo ""
