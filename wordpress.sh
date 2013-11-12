#!/bin/bash

# Get website URL and backend path

echo ""
echo ""
echo "$(tput bold)$(tput setaf 6)CentOS WordPress by GigabyteIO$(tput sgr0)"
echo "Home URL : http://gigabyte.io"
echo "Github URL: https://github.com/GigabyteIO/CentOS-WordPress"
echo "Author : Brian Zalewski"
echo ""
echo ""
read -p 'Enter WordPress homepage URL (e.g. yourwebsite.com): ' CLI_WEBSITE
echo ""
echo "$(tput bold)$(tput setaf 7)Read Me:$(tput sgr0) Using the following prompt you will specify the folder that the WordPress core files are installed to (e.g. http://yourwebsite.com/BACKEND_PATH_HERE/wp-login). This improves security, provides better organization, and makes updating WordPress easier for those who would like to clone the latest WordPress development release."
echo ""
read -p 'Enter a backend path for improved security: ' CLI_BACKEND_PATH
echo ""
echo "* $(tput setaf 6)Copying centmin-wordpress.exp from /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER to /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME$(tput sgr0)"
cp /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER/centmin-wordpress.exp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-wordpress.exp
echo "* $(tput setaf 6)Giving centmin-wordpress.exp executable permissions$(tput sgr0)"
chmod +x centmin-wordpress.exp
echo "* $(tput setaf 6)Giving centmin.sh executable permissions$(tput sgr0)"
chmod +x centmin.sh
echo "* $(tput setaf 6)Initializing the CentminMod website setup via centmin-wordpress.exp$(tput sgr0)"
./centmin-install.exp "$CLI_WEBSITE"
echo "* $(tput setaf 6)Removing centmin-wordpress.exp from CentminMod folder$(tput sgr0)"
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin-wordpress.exp
echo "* $(tput setaf 6)Restoring centmin.sh permissions to original state$(tput sgr0)"
chmod 644 /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
echo "* $(tput setaf 6)Declaring potentially customizable script variables in wordpress.sh$(tput sgr0)"
# Get MySQL host from envoirnment variables
CLI_DATABASE_HOST=$DATABASE_SERVER
# Default for CentminMod - change if using custom directory schema
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'
# Default location for GigabyteIO
POOR_IO_HOME='usr/local/src/gigabyteio'
# Default location for nginx configuration files
NGINX_CONF_DIR='usr/local/nginx/conf'
# Remove default error pages and create backend path directory
echo "* $(tput setaf 6)Removing default website files from /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public$(tput sgr0)"
rm -rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/*
echo "* $(tput setaf 6)Creating backend path directory$(tput sgr0)"
mkdir -v /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH

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
echo "* $(tput setaf 6)Copying wp-config.php template from /$POOR_IO_HOME/files/wp-config-options.php to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php$(tput sgr0)"
cp /$POOR_IO_HOME/files/wp-config-options.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
echo "* $(tput setaf 6)Inserting database connection settings into wp-config.php$(tput sgr0)"
perl -pi -e 's/DB_NAME_HANDLE/$CLI_DATABASE_NAME/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_USER_HANDLE/$CLI_DATABASE_USER/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_PASSWORD_HANDLE/$CLI_DATABASE_PASSWORD/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/TABLE_PREFIX_HANDLE/$CLI_PREFIX_RANDOM/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
echo "* $(tput setaf 6)Inserting secure keys from https://api.wordpress.org/secret-key/1.1/salt/ into wp-config.php$(tput sgr0)"
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config.php
echo "* $(tput setaf 6)Inserting the backend path into wp-config.php$(tput sgr0)"
perl -pi -e 's/BACKEND_PATH_HANDLE/$CLI_BACKEND_PATH/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php

# Download WordPress core files
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
echo "* $(tput setaf 6)Downloading latest WordPress release from http://wordpress.org/latest.tar.gz$(tput sgr0)"
wget http://wordpress.org/latest.tar.gz
echo "* $(tput setaf 6)Decompressing latest.tar.gz$(tput sgr0)"
tar -xzvf latest.tar.gz
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
mkdir addons
echo "* $(tput setaf 6)Creating custom mu-plugin directory$(tput sgr0)"
mkdir includes

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
git clone https://github.com/Automattic/batcache.git
echo "* $(tput setaf 6)Cloning APC cache plugin$(tput sgr0)"
git clone https://github.com/eremedia/APC.git

# Add plugins
echo "* $(tput setaf 6)Changing directory to custom plugins folder$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons
echo "* $(tput setaf 6)Cloning Yoast WordPress SEO latest developement version plugin$(tput sgr0)"
git clone https://github.com/Yoast/wordpress-seo.git wordpress-seo
echo "* $(tput setaf 6)Downloading MP6 plugin from wordpress.org$(tput sgr0)"
wget http://downloads.wordpress.org/plugin/mp6.zip
echo "* $(tput setaf 6)Unzipping mp6.zip$(tput sgr0)"
unzip mp6.zip
echo "* $(tput setaf 6)Removing mp6.zip$(tput sgr0)"
rm -f mp6.zip
echo "* $(tput setaf 6)Downloading Google Authenticator plugin from wordpress.org$(tput sgr0)"
wget http://downloads.wordpress.org/plugin/google-authenticator.0.44.zip
echo "* $(tput setaf 6)Unzipping google-authenticator.0.44.zip$(tput sgr0)"
unzip google-authenticator.0.44.zip
echo "* $(tput setaf 6)Removing google-authenticator.0.44.zip$(tput sgr0)"
rm -f google-authenticator.0.44.zip
echo "* $(tput setaf 6)Downloading Pods plugin from wordpress.org$(tput sgr0)"
wget http://downloads.wordpress.org/plugin/pods.2.3.18.zip
echo "* $(tput setaf 6)Unzipping pods.2.3.18.zip$(tput sgr0)"
unzip pods.2.3.18.zip
echo "* $(tput setaf 6)Removing pods.2.3.18.zip$(tput sgr0)"
rm -f pods.2.3.18.zip
echo "* $(tput setaf 6)Downloading My Shortcodes plugin from wordpress.org$(tput sgr0)"
wget http://downloads.wordpress.org/plugin/my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Unzipping my-shortcodes.2.06.zip$(tput sgr0)"
unzip my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Removing my-shortcodes.2.06.zip$(tput sgr0)"
rm -f my-shortcodes.2.06.zip
echo "* $(tput setaf 6)Downloading SEO Automatic Links plugin from wordpress.org$(tput sgr0)"
wget http://downloads.wordpress.org/plugin/seo-automatic-links.zip
echo "* $(tput setaf 6)Unzipping seo-automatic-links.zip$(tput sgr0)"
unzip seo-automatic-links.zip
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
wget http://downloads.wordpress.org/plugin/rename-wp-login.1.7.zip
echo "* $(tput setaf 6)Unzipping rename-wp-login.1.7.zip$(tput sgr0)"
unzip rename-wp-login.1.7.zip
echo "* $(tput setaf 6)Removing rename-wp-login.1.7.zip$(tput sgr0)"
rm -f rename-wp-login.1.7.zip
echo "* $(tput setaf 6)Cloning options-framework latest development version plugin$(tput sgr0)"
git clone https://github.com/devinsays/options-framework-plugin.git options-framework

# Add must-use plugins
echo "* $(tput setaf 6)Adding php-widget.php to must-use plugin directory from /$POOR_IO_HOME/wordpress$(tput sgr0)"
cp /$POOR_IO_HOME/wordpress/php-widget.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/php-widget.php
echo "* $(tput setaf 6)Adding default-settings-plugin.php to must-use plugin directory from /$POOR_IO_HOME/wordpress$(tput sgr0)"
cp /$POOR_IO_HOME/wordpress/default-settings-plugin.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/default-settings-plugin.php

# Move caching plugin files to appropriate directories
echo "* $(tput setaf 6)Installing batcache to appropriate folders$(tput sgr0)"
cp /$POOR_IO_HOME/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
cp /$POOR_IO_HOME/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons/batcache.php
echo "* $(tput setaf 6)Installing APC object-cache plugin to appropriate folder$(tput sgr0)"
cp /$POOR_IO_HOME/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php

# Add latest version of Roots IO (see http://roots.io/)
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
echo "* $(tput setaf 6)Cloning latest release of the Roots.IO theme$(tput sgr0)"
git clone https://github.com/roots/roots.git

# Set nginx as owner
echo "* $(tput setaf 6)Recursively changing ownership of /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public to nginx$(tput sgr0)"
chown -Rf nginx:nginx /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public

# Remove default configuration and add new, optimized one
echo "* $(tput setaf 6)Removing the default nginx configuration for current website$(tput sgr0)"
rm -f /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
echo "* $(tput setaf 6)Copying nginx configuration template from /$POOR_IO_HOME/files/wordpress-optimized-nginx-config.conf to /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf$(tput sgr0)"
cp /$POOR_IO_HOME/files/wordpress-optimized-nginx-config.conf /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
echo "* $(tput setaf 6)Adjusting template for current website$(tput sgr0)"
perl -pi -e 's/REPLACETHIS/$CLI_WEBSITE/g' /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
perl -pi -e 's/BACKENDPATH/$CLI_BACKEND_PATH/g' /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
# Chown it up here.
echo "* $(tput setaf 6)Restarting nginx to update configuration settings$(tput sgr0)"
service nginx restart
