#!/bin/bash

# Get website URL and backend path
CLI_WEBSITE=$1
SITE_TITLE=$2
CLI_BACKEND_PATH=$3
ADMIN_USER=$4
ADMIN_PASSWORD=$5
PASSWORD_CHECK=$5
ADMIN_EMAIL=$6
echo ""
echo "$(tput bold)$(tput setaf 6)Setting up a new WordPress website...$(tput sgr0)"
echo ""
read -p 'Enter WordPress homepage URL (e.g. yourwebsite.com): ' CLI_WEBSITE
echo ""
read -p "Enter a website title for $CLI_WEBSITE: " SITE_TITLE
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) Using the following prompt you will specify the folder that the WordPress core files are installed to (e.g. http://yourwebsite.com/BACKEND_PATH_HERE/wp-login). This improves security, provides better organization, and makes updating WordPress easier for those who would like to clone the latest WordPress development release."
echo ""
read -p 'Enter a backend path for improved security: ' CLI_BACKEND_PATH
echo ""
read -p "Enter the WordPress administrator's user name: " ADMIN_USER
echo ""
read -s -p "Enter the WordPress administrator's password: " ADMIN_PASSWORD
echo ""
read -s -p "Re-enter the WordPress administrator password: " PASSWORD_CHECK
while [ "$ADMIN_PASSWORD" != "$PASSWORD_CHECK" ]; do 
    echo ""
    echo "Passwords did not match. Try again."
    echo ""
    read -s -p "Enter the WordPress administrator password: " ADMIN_PASSWORD
    echo ""
    read -s -p "Re-enter the WordPress administrator password: " PASSWORD_CHECK
done
echo ""
read -p "Enter the WordPress administrator's e-mail address: " ADMIN_EMAIL
until [[ "$ADMIN_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; do
    echo "$ADMIN_EMAIL is an invalid e-mail address format. Try again."
    echo ""
    read -p "Enter the WordPress administrator's e-mail address: " ADMIN_EMAIL
done
echo ""
echo "* $(tput setaf 6)Declaring potentially customizable script variables in wordpress.sh$(tput sgr0)"
# NOTE: NOT ALL OF THESE VARIABLES ARE REQUIRED... THEY WERE COPIED FROM setup.sh
# Get MySQL host from envoirnment variables
CLI_DATABASE_HOST='localhost'
# Default for CentminMod - change if using custom directory schema
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'
# Default location for GigabyteIO
POOR_IO_HOME='usr/local/src/gigabyteio'
# Default location for nginx configuration files
NGINX_CONF_DIR='usr/local/nginx/conf'
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
echo "* $(tput setaf 6)Copying centmin-wordpress.exp from /$POOR_IO_HOME/$SCRIPTS_FOLDER to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cp /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/centmin-wordpress.exp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-wordpress.exp
echo "* $(tput setaf 6)Changing directory to /$CENTMIN_DIR/$INSTALL_FOLDER_NAME$(tput sgr0)"
cd /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME
echo "* $(tput setaf 6)Giving centmin-wordpress.exp executable permissions$(tput sgr0)"
chmod +x centmin-wordpress.exp
echo "* $(tput setaf 6)Giving centmin.sh executable permissions$(tput sgr0)"
chmod +x centmin.sh
echo "* $(tput setaf 6)Initializing the CentminMod website setup via centmin-wordpress.exp$(tput sgr0)"
./centmin-wordpress.exp "$CLI_WEBSITE"
echo "* $(tput setaf 6)Removing centmin-wordpress.exp from CentminMod folder$(tput sgr0)"
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-wordpress.exp
echo "* $(tput setaf 6)Restoring centmin.sh permissions to original state$(tput sgr0)"
chmod 644 /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Remove default error pages and create backend path directory
echo "* $(tput setaf 6)Removing default website files from /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public$(tput sgr0)"
rm -rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/*
echo "* $(tput setaf 6)Creating backend path directory$(tput sgr0)"
mkdir /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH

# Generate random MySQL credentials and create the database
echo "* $(tput setaf 6)Generating random ~8 character database name$(tput sgr0)"
CLI_DATABASE_NAME=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
echo "* $(tput setaf 6)Generating random ~8 character database user name$(tput sgr0)"
CLI_DATABASE_USER=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
echo "* $(tput setaf 6)Generating random ~4 character database table prefix$(tput sgr0)"
CLI_PREFIX_RANDOM=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
echo "* $(tput setaf 6)Generating random ~64 character database password$(tput sgr0)"
CLI_DATABASE_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')
echo "* $(tput setaf 6)Creating database with randomly generated fields$(tput sgr0)"
echo ""
echo "Your root MySQL password is required. Please enter your MySQL root password:"
mysql -uroot -p --verbose -e "CREATE DATABASE $CLI_DATABASE_NAME; GRANT ALL PRIVILEGES ON $CLI_DATABASE_NAME.* TO '$CLI_DATABASE_USER'@'$CLI_DATABASE_HOST' IDENTIFIED BY '$CLI_DATABASE_PASSWORD'; FLUSH PRIVILEGES"

# Set up wp-config.php
echo "* $(tput setaf 6)Copying wp-config.php template from /$POOR_IO_HOME/$WORDPRESS_FOLDER/wp-config-options.php to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/wp-config-options.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
echo "* $(tput setaf 6)Inserting database connection settings into wp-config.php$(tput sgr0)"
sed -i "s/DB_NAME_HANDLE/$CLI_DATABASE_NAME/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
sed -i "s/DB_USER_HANDLE/$CLI_DATABASE_USER/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
sed -i "s/DB_PASSWORD_HANDLE/$CLI_DATABASE_PASSWORD/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
sed -i "s/TABLE_PREFIX_HANDLE/$CLI_PREFIX_RANDOM/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
echo "* $(tput setaf 6)Inserting secure keys from https://api.wordpress.org/secret-key/1.1/salt/ into wp-config.php$(tput sgr0)"
perl -i -pe '
  BEGIN { 
    $keysalts = qx(curl -sS https://api.wordpress.org/secret-key/1.1/salt) 
  } 
  s/{AUTH-KEYS-SALTS}/$keysalts/g
' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
echo "* $(tput setaf 6)Inserting the backend path ($CLI_BACKEND_PATH) into wp-config.php$(tput sgr0)"
sed -i "s/BACKEND_PATH_HANDLE/$CLI_BACKEND_PATH/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
# Download WordPress core files
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
echo "* $(tput setaf 6)Downloading latest WordPress release from http://wordpress.org/latest.tar.gz$(tput sgr0)"
wget -q http://wordpress.org/latest.tar.gz
echo "* $(tput setaf 6)Decompressing latest.tar.gz$(tput sgr0)"
tar -xzf latest.tar.gz
echo "* $(tput setaf 6)Copying files from decompressed folder to the backend path$(tput sgr0)"
cp -Rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wordpress/* /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/
echo "* $(tput setaf 6)Removing copied files$(tput sgr0)"
rm -Rf wordpress
echo "* $(tput setaf 6)Removing latest.tar.gz$(tput sgr0)"
rm -f latest.tar.gz

# Create customized structure
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
echo "* $(tput setaf 6)Creating custom wp-content directory$(tput sgr0)"
mkdir content
echo "* $(tput setaf 6)Creating custom plugin directory$(tput sgr0)"
mkdir content/plugins
echo "* $(tput setaf 6)Creating custom mu-plugin directory$(tput sgr0)"
mkdir includes
echo "* $(tput setaf 6)Creating themes directory in the custom wp-content directory$(tput sgr0)"
mkdir content/themes

# Download drop-in caching plugins from Git
echo "* $(tput setaf 6)Changing directory to /$POOR_IO_HOME$(tput sgr0)"
cd /$POOR_IO_HOME
echo "* $(tput setaf 6)Removing gitclones folder (just in case it is already there)$(tput sgr0)"
rm -Rf gitclones
echo "* $(tput setaf 6)Creating new gitclones folder$(tput sgr0)"
mkdir gitclones
echo "* $(tput setaf 6)Changing directory to gitclones folder$(tput sgr0)"
cd gitclones
echo "* $(tput setaf 6)Cloning batcache plugin$(tput sgr0)"
git clone -q https://github.com/Automattic/batcache.git
echo "* $(tput setaf 6)Cloning APC cache plugin$(tput sgr0)"
git clone -q https://github.com/eremedia/APC.git

# Add plugins
echo "* $(tput setaf 6)Changing directory to custom plugins folder$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/addons
echo "* $(tput setaf 6)Cloning Yoast WordPress SEO latest developement version plugin$(tput sgr0)"
git clone -q https://github.com/Yoast/wordpress-seo.git wordpress-seo
echo "* $(tput setaf 6)Downloading MP6 plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/mp6.zip
echo "* $(tput setaf 6)Unzipping mp6.zip$(tput sgr0)"
unzip -q mp6.zip
echo "* $(tput setaf 6)Removing mp6.zip$(tput sgr0)"
rm -f mp6.zip
echo "* $(tput setaf 6)Downloading Google Authenticator plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/google-authenticator.0.44.zip
echo "* $(tput setaf 6)Unzipping google-authenticator.0.44.zip$(tput sgr0)"
unzip -q google-authenticator.0.44.zip
echo "* $(tput setaf 6)Removing google-authenticator.0.44.zip$(tput sgr0)"
rm -f google-authenticator.0.44.zip
echo "* $(tput setaf 6)Downloading Pods plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/pods.2.3.18.zip
echo "* $(tput setaf 6)Unzipping pods.2.3.18.zip$(tput sgr0)"
unzip -q pods.2.3.18.zip
echo "* $(tput setaf 6)Removing pods.2.3.18.zip$(tput sgr0)"
rm -f pods.2.3.18.zip
echo "* $(tput setaf 6)Downloading My Shortcodes plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Unzipping my-shortcodes.2.06.zip$(tput sgr0)"
unzip -q my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Removing my-shortcodes.2.06.zip$(tput sgr0)"
rm -f my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Downloading SEO Automatic Links plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/seo-automatic-links.zip
echo "* $(tput setaf 6)Unzipping seo-automatic-links.zip$(tput sgr0)"
unzip -q seo-automatic-links.zip
echo "* $(tput setaf 6)Removing seo-automatic-links.zip$(tput sgr0)"
rm -f seo-automatic-links.zip
#More research offline alternatives
#wget http://downloads.wordpress.org/plugin/broken-link-checker.1.9.1.zip
#unzip broken-link-checker.1.9.1.zip
#rm -f broken-link-checker.1.9.1.zip
#More research alternatives
#wget http://downloads.wordpress.org/plugin/safe-redirect-manager.1.7.zip
#unzip safe-redirect-manager.1.7.zip
#rm -f safe-redirect-manager.1.7.zip
#If Yoast SEO maps cant owrk:
#wget http://downloads.wordpress.org/plugin/google-sitemap-generator.3.3.zip
#unzip google-sitemap-generator.3.3.zip
#rm -f google-sitemap-generator.3.3.zip
echo "* $(tput setaf 6)Downloading Rename WP Login plugin from wordpress.org$(tput sgr0)"
wget -q http://downloads.wordpress.org/plugin/rename-wp-login.1.7.zip
echo "* $(tput setaf 6)Unzipping rename-wp-login.1.7.zip$(tput sgr0)"
unzip -q rename-wp-login.1.7.zip
echo "* $(tput setaf 6)Removing rename-wp-login.1.7.zip$(tput sgr0)"
rm -f rename-wp-login.1.7.zip
#echo "* $(tput setaf 6)Cloning options-framework latest development version plugin$(tput sgr0)"
#git clone -q https://github.com/devinsays/options-framework-plugin.git options-framework

# Add must-use plugins
echo "* $(tput setaf 6)Adding php-widget.php to must-use plugin directory from /$POOR_IO_HOME/$WORDPRESS_FOLDER$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/php-widget.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/includes/php-widget.php
echo "* $(tput setaf 6)Adding default-settings-plugin.php to must-use plugin directory from /$POOR_IO_HOME/$WORDPRESS_FOLDER$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/default-settings-plugin.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/includes/default-settings-plugin.php

# Move caching plugin files to appropriate directories
echo "* $(tput setaf 6)Installing batcache to appropriate folders$(tput sgr0)"
cp /$POOR_IO_HOME/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
cp /$POOR_IO_HOME/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/addons/batcache.php
echo "* $(tput setaf 6)Installing APC object-cache plugin to appropriate folder$(tput sgr0)"
cp /$POOR_IO_HOME/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php

# Add latest version of Shoestrap
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
echo "* $(tput setaf 6)Getting custom version of Roots.IO$(tput sgr0)"
git clone -q https://github.com/GigabyteIO/roots.git

# Remove default configuration and add new, optimized one
echo "* $(tput setaf 6)Removing the default nginx configuration for current website$(tput sgr0)"
rm -f /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
echo "* $(tput setaf 6)Copying nginx configuration template from /$POOR_IO_HOME/$CONF_FOLDER/wordpress-optimized-nginx-config.conf to /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf$(tput sgr0)"
cp /$POOR_IO_HOME/$CONF_FOLDER/wordpress-optimized-nginx-config.conf /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
echo "* $(tput setaf 6)Copying robots.txt from /$POOR_IO_HOME/$WORDPRESS_FOLDER to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/robots.txt /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
echo "* $(tput setaf 6)Copying index.php from /$POOR_IO_HOME/$WORDPRESS_FOLDER to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index-template.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/index.php
echo "* $(tput setaf 6)Adjusting index.php to point to custom WordPress directory$(tput sgr0)"
sed -i "s/BACKENDPATH/$CLI_BACKEND_PATH/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/index.php
echo "* $(tput setaf 6)Adjusting nginx configuration for current website$(tput sgr0)"
sed -i "s/REPLACETHIS/$CLI_WEBSITE/g" /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
sed -i "s/BACKENDPATH/$CLI_BACKEND_PATH/g" /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf

echo "* $(tput setaf 6)Adding \"Silence is golden\" index.php file to all custom directories$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/addons
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/includes
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
echo "* $(tput setaf 6)Installing WP-CLI$(tput sgr0)"
curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
echo "* $(tput setaf 6)Installing WordPress for $CLI_WEBSITE$(tput sgr0)"
/root/.wp-cli/bin/wp core install --path=$CLI_BACKEND_PATH --url=$CLI_WEBSITE --title=$SITE_TITLE --admin_user=$ADMIN_USER --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL
# Set nginx as owner
echo "* $(tput setaf 6)Recursively changing ownership of /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public to nginx$(tput sgr0)"
chown -Rf nginx:nginx /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
echo "* $(tput setaf 6)Removing unnecessary files from WordPress$(tput sgr0)"
rm /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wp-config-sample.php
rm /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/readme.html
rm /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/license.txt
# Chown it up here.
echo "* $(tput setaf 6)Restarting nginx to update configuration settings$(tput sgr0)"
service nginx restart
