#!/bin/bash -x

# Change the root password (supplied in user_variables.sh)
echo -e "$root_password\n$root_password" | (passwd --stdin $USER)

# Set up new root user and root password
egrep "^$new_root_username" /etc/passwd >/dev/null
encrypted_new_root_password=$(perl -e 'print crypt($ARGV[0], "password")' $new_root_password)
useradd -m -p $encrypted_new_root_password $new_root_username

# Set memcached password to random password
memcached_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c16 | tr -d '-')

# Collect IP information
ssh_client_ip_address=$(echo $SSH_CONNECTION | cut -f1 -d' ')
ssh_server_ip_address=$(echo $SSH_CONNECTION | cut -f3 -d' ')
ip_address=$(curl -silent ifconfig.me)

# Update system
yum -y --exclude=kernel* --exclude=setup* update

# Add new root user to visudo list
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER$(tput sgr0)"
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
echo "* $(tput setaf 6)Granting executable permissions to visudo.sh$(tput sgr0)"
chmod +x visudo.sh
echo "* $(tput setaf 6)Giving root permissions to $NEW_ROOT_USERNAME using visudo.sh$(tput sgr0)"
./visudo.sh $NEW_ROOT_USERNAME
echo "* $(tput setaf 6)Restoring visudo.sh permissions to original state$(tput sgr0)"
chmod 644 visudo.sh
# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
        echo "* $(tput setaf 6)Creating .ssh directory in $NEW_ROOT_USER_NAME's home directory$(tput sgr0)"
        mkdir /home/$NEW_ROOT_USERNAME/.ssh
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
echo "* $(tput setaf 6)Changing TCP packet header to MegabyteIO in centmin.sh$(tput sgr0)"
perl -pi -e 's/nginx centminmod/MegabyteIO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Install CentminMod with expect script to automate user inputs
echo "* $(tput setaf 6)Copying centmin-install.exp from /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cp /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/centmin-install.exp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-install.exp
echo "* $(tput setaf 6)Giving centmin-install.exp executable permissions$(tput sgr0)"
chmod +x centmin-install.exp
echo "* $(tput setaf 6)Giving centmin.sh executable permissions$(tput sgr0)"
chmod +x centmin.sh
echo "* $(tput setaf 6)Initializing the CentminMod install process via centmin-install.exp$(tput sgr0)"
# Usage ./centmin-install.exp mysqlpass memcacheusername memcachepassword
./centmin-install.exp "$NEW_ROOT_PASSWORD" "MegabyteIO" "$MEMCACHED_PWORD"
echo ""
echo "$(tput bold)$(tput setaf 2)CentminMod base installation complete$(tput sgr0)"
echo ""
echo "* $(tput setaf 6)Copying centmin-ssh.exp from /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cp /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/centmin-ssh.exp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-ssh.exp
echo "* $(tput setaf 6)Giving centmin-ssh.exp executable permissions$(tput sgr0)"
chmod +x centmin-ssh.exp
echo "* $(tput setaf 6)Using CentminMod to change the SSH port via centmin-ssh.exp$(tput sgr0)"
./centmin-ssh.exp "22" "$SSH_PORT_NUMBER"
# Change permissions of centmin.sh and centmin-install.exp back to original
echo "* $(tput setaf 6)Removing centmin-install.exp from CentminMod folder$(tput sgr0)"
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-install.exp
echo "* $(tput setaf 6)Removing centmin-ssh.exp from CentminMod folder$(tput sgr0)"
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-ssh.exp
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
echo "* $(tput setaf 6)Installing WP-CLI$(tput sgr0)"
curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
echo "* $(tput setaf 6)Sourcing WP-CLI aliases$(tput sgr0)"
echo 'export PATH=/root/.wp-cli/bin:$PATH' >> ~/.bash_profile
if [ $CLOUDFLARE_YESNO = yes ]; then
echo "* $(tput setaf 6)Opening the Cloudflare DNS configuration script$(tput sgr0)"
URL_FUTURE='blah' # unimportant variable - not used
# SYNTAX FOR USE: ./cloudflare-domains.sh [cloudflare email address] [cloudflare API key] [Google Apps choice google|off] [Custom set up for each domain on|off] [github ID yyourID|off] [wordpress auto install yes|no] [admin_email] [url] [default_title] [wp_admin] [wp_admin_pass]
bash cloudflare-domains.sh $CLOUDFLARE_EMAIL_ADDRESS $CLOUDFLARE_API_KEY $APPS_SETTINGS $CLOUDFLARE_ALL_WEBSITES $GITHUB_ID $CLOUDFLARE_WP_YESNO $WORDPRESS_ADMIN_EMAIL $URL_FUTURE $DEFAULT_WORDPRESS_INSTALL_TITLE $WORDPRESS_ADMIN_USER $WORDPRESS_ADMIN_PASSWORD $NEW_ROOT_PASSWORD
fi
echo ""
echo ""
echo "$(tput bold)$(tput setaf 2)Installation Complete$(tput sgr0)"
echo ""
echo "$(tput bold)$(tput setaf 6)Thanks for choosing CentOS WordPress$(tput sgr0)"
echo "Home URL  : http://megabyte.io"
echo "Github URL: https://github.com/MByteIO/CentOS-WordPress"
echo "Author    : Brian Zalewski"
echo "Credit to CentminMod! Check out their website at http://centminmod.com/!"
echo ""
echo ""
echo "Set up DKIM e-mail authentication by going to admin.google.com -> Google Apps -> GMail -> Authenticate E-Mail."
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) You should now restart the server. You can also test to make sure the web server works by going to your IP address in a browser. After you restart the server, you can automatically install, configure, and optimize a WordPress website by running:"
echo ""
echo "     $(tput bold)$(tput setaf 7)bash /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/wordpress.sh$(tput sgr0)"
echo ""
