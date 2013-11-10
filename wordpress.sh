#!/bin/sh

# Get MySQL host from envoirnment variables
CLI_DATABASE_HOST=$DATABASE_SERVER
# Default for CentminMod - change if using custom directory schema
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'
# Default location for PoorIO
POOR_IO_HOME='usr/local/src/PoorIO'
# Default location for nginx configuration files
NGINX_CONF_DIR='usr/local/nginx/conf'

# Get website URL and backend path
read -p 'Enter WordPress homepage URL (IMPORTANT: Enter the URL in the following format - yourwebsite.com): ' CLI_WEBSITE
read -p 'Enter a backend path for improved security (e.g. http://yourwebsite.com/BACKEND-PATH/wp-admin): ' CLI_BACKEND_PATH

# Remove default error pages and create backend path directory
rm -rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/*
mkdir -v /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH

# Generate random MySQL credentials and create the database
CLI_DATABASE_NAME=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_DATABASE_USER=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_PREFIX_RANDOM=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
CLI_DATABASE_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')
echo "Creating database with random variables used for database name, username, and password. Your root MySQL password is required. Please enter your MySQL root password:"
mysql -uroot -p --verbose -e "CREATE DATABASE $CLI_DATABASE_NAME; GRANT ALL PRIVILEGES ON $CLI_DATABASE_NAME.* TO '$CLI_DATABASE_USER'@'$CLI_DATABASE_HOST' IDENTIFIED BY '$CLI_DATABASE_PASSWORD'; FLUSH PRIVILEGES"

# Set up wp-config.php
cp /$POOR_IO_HOME/files/wp-config-options.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_NAME_HANDLE/$CLI_DATABASE_NAME/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_USER_HANDLE/$CLI_DATABASE_USER/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_PASSWORD_HANDLE/$CLI_DATABASE_PASSWORD/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/TABLE_PREFIX_HANDLE/$CLI_PREFIX_RANDOM/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config.php
perl -pi -e 's/BACKEND_PATH_HANDLE/$CLI_BACKEND_PATH/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php

# Download WordPress core files
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp -Rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wordpress/* /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/
rm -Rf wordpress
rm -f latest.tar.gz

# Create customized structure
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
mkdir content
mkdir addons
mkdir includes

# Download drop-in caching plugins from Git
cd /$POOR_IO_HOME
rm -Rf gitclones
mkdir gitclones
cd gitclones
git clone https://github.com/Automattic/batcache.git
git clone https://github.com/eremedia/APC.git

# Add plugins
cd /$POOR_IO_HOME
rm -Rf zipclones
mkdir zipclones
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons
git clone https://github.com/Yoast/wordpress-seo.git wordpress-seo
wget http://downloads.wordpress.org/plugin/mp6.zip
unzip mp6.zip
rm -f mp6.zip
wget http://downloads.wordpress.org/plugin/google-authenticator.0.44.zip
unzip google-authenticator.0.44.zip
rm -f google-authenticator.0.44.zip
wget http://downloads.wordpress.org/plugin/pods.2.3.18.zip
unzip pods.2.3.18.zip
rm -f pods.2.3.18.zip
wget http://downloads.wordpress.org/plugin/my-shortcodes.2.06.zip
unzip my-shortcodes.2.06.zip
rm -f my-shortcodes.2.06.zip
wget http://downloads.wordpress.org/plugin/seo-automatic-links.zip
unzip seo-automatic-links.zip
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
wget http://downloads.wordpress.org/plugin/rename-wp-login.1.7.zip
unzip rename-wp-login.1.7.zip
rm -f rename-wp-login.1.7.zip
git clone https://github.com/devinsays/options-framework-plugin.git options-framework

# Add must-use plugins
cp /$POOR_IO_HOME/files/php-widget.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/php-widget.php
cp /$POOR_IO_HOME/files/default-settings-plugin.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/default-settings-plugin.php

# Move caching plugin files to appropriate directories
cp /$POOR_IO_HOME/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
cp /$POOR_IO_HOME/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons/batcache.php
cp /$POOR_IO_HOME/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php

# Add latest version of Roots IO (see http://roots.io/)
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
git clone https://github.com/roots/roots.git

# Set nginx as owner
chown -Rf nginx:nginx /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public

# Remove default configuration and add new, optimized one
rm -f /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
cp /$POOR_IO_HOME/files/wordpress-optimized-nginx-config.conf /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
perl -pi -e 's/REPLACETHIS/$CLI_WEBSITE/g' /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
perl -pi -e 's/BACKENDPATH/$CLI_BACKEND_PATH/g' /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
# Chown it up here.
service nginx restart
