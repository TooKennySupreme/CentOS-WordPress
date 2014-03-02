#!/bin/bash

# Usage: wordpress_install website
function custom_wordpress_install {
	# Remove base files from public folder
	rm -rf "$website_dir""$1"'/public/'*
	mkdir "$website_dir""$1"'/public/'"$custom_backend"
	
	# Generate random MySQL credentials and random table prefix
	database_name=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	database_user=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	random_prefix=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
	database_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')

	# Create database
  mysql -uroot -p"$mysql_password" --verbose -e "CREATE DATABASE $database_name; GRANT ALL PRIVILEGES ON $database_name.* TO '$database_user'@'$database_host' IDENTIFIED BY '$database_password'; FLUSH PRIVILEGES"
  
  cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/wp-mu-config.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/private/wp-config.php
}
# Set up wp-config.php
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
mkdir addons
echo "* $(tput setaf 6)Creating custom mu-plugin directory$(tput sgr0)"
mkdir includes
echo "* $(tput setaf 6)Creating themes directory in the custom wp-content directory$(tput sgr0)"
mkdir content/themes

# Download drop-in caching plugins from Git
echo "* $(tput setaf 6)Changing directory to /$POOR_IO_HOME$(tput sgr0)"
cd /$POOR_IO_HOME
#echo "* $(tput setaf 6)Removing gitclones folder (just in case it is already there)$(tput sgr0)"
#rm -Rf gitclones
#echo "* $(tput setaf 6)Creating new gitclones folder$(tput sgr0)"
#mkdir gitclones
#echo "* $(tput setaf 6)Changing directory to gitclones folder$(tput sgr0)"
#cd gitclones
#echo "* $(tput setaf 6)Cloning batcache plugin$(tput sgr0)"
#git clone -q https://github.com/Automattic/batcache.git
#echo "* $(tput setaf 6)Cloning APC cache plugin$(tput sgr0)"
#git clone -q https://github.com/eremedia/APC.git

# Add plugins
echo "* $(tput setaf 6)Changing directory to custom plugins folder$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons
#echo "* $(tput setaf 6)Downloading My Shortcodes plugin from wordpress.org$(tput sgr0)"
#wget -q http://downloads.wordpress.org/plugin/my-shortcodes.2.06.zip
#echo "* $(tput setaf 6)Unzipping my-shortcodes.2.06.zip$(tput sgr0)"
#unzip -q my-shortcodes.2.06.zip
#echo "* $(tput setaf 6)Removing my-shortcodes.2.06.zip$(tput sgr0)"
#rm -f my-shortcodes.2.06.zip
#echo "* $(tput setaf 6)Downloading SEO Automatic Links plugin from wordpress.org$(tput sgr0)"
#wget -q http://downloads.wordpress.org/plugin/seo-automatic-links.zip
#echo "* $(tput setaf 6)Unzipping seo-automatic-links.zip$(tput sgr0)"
#unzip -q seo-automatic-links.zip
#echo "* $(tput setaf 6)Removing seo-automatic-links.zip$(tput sgr0)"
#rm -f seo-automatic-links.zip
#More research offline alternatives
# RUN ON ANOTHER SERVER
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
#echo "* $(tput setaf 6)Downloading Rename WP Login plugin from wordpress.org$(tput sgr0)"
# MOVE TO INCLUDES
#wget -q http://downloads.wordpress.org/plugin/rename-wp-login.1.7.zip
#echo "* $(tput setaf 6)Unzipping rename-wp-login.1.7.zip$(tput sgr0)"
#unzip -q rename-wp-login.1.7.zip
#echo "* $(tput setaf 6)Removing rename-wp-login.1.7.zip$(tput sgr0)"
#rm -f rename-wp-login.1.7.zip
#echo "* $(tput setaf 6)Cloning options-framework latest development version plugin$(tput sgr0)"
#git clone -q https://github.com/devinsays/options-framework-plugin.git options-framework

# Add must-use plugins
echo "* $(tput setaf 6)Adding php-widget.php to must-use plugin directory from /$POOR_IO_HOME/$WORDPRESS_FOLDER$(tput sgr0)"
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/php-widget.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/php-widget.php
#echo "* $(tput setaf 6)Adding default-settings-plugin.php to must-use plugin directory from /$POOR_IO_HOME/$WORDPRESS_FOLDER$(tput sgr0)"
#cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/default-settings-plugin.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/default-settings-plugin.php

# Move caching plugin files to appropriate directories
#echo "* $(tput setaf 6)Installing batcache to appropriate folders$(tput sgr0)"
#cp /$POOR_IO_HOME/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
#cp /$POOR_IO_HOME/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/addons/batcache.php
#echo "* $(tput setaf 6)Installing APC object-cache plugin to appropriate folder$(tput sgr0)"
#cp /$POOR_IO_HOME/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php

# Add latest version of Roots
echo "* $(tput setaf 6)Changing directory to /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
echo "* $(tput setaf 6)Getting custom version of Roots.IO$(tput sgr0)"
git clone -q $GITHUB_URL

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
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content
cp /$POOR_IO_HOME/$WORDPRESS_FOLDER/index.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
echo "* $(tput setaf 6)Changing directory to web root of $CLI_WEBSITE$(tput sgr0)"
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
echo "* $(tput setaf 6)Installing WordPress for $CLI_WEBSITE$(tput sgr0)"
source ~/.bash_profile
wp core install --path="$CLI_BACKEND_PATH" --url="$CLI_WEBSITE" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL"
echo "* $(tput setaf 6)Installing plugins$(tput sgr0)"
wp plugin install --activate mp6 --path='cms' --url="$CLI_WEBSITE"
wp plugin install --activate front-end-editor --path='cms' --url="$CLI_WEBSITE"
#wp plugin install --activate wordpress-seo --path='cms' --url="$CLI_WEBSITE"
# Install SEOProfessor - Yoast tries to do too many things all at the same time
wp plugin install --activate my-shortcodes --path='cms' --url="$CLI_WEBSITE"
wp plugin install --activate redirection --path='cms' --url="$CLI_WEBSITE"
wp plugin install --activate google-sitemap-generator --path='cms' --url="$CLI_WEBSITE"
wp plugin install pods --path='cms' --url="$CLI_WEBSITE"
wp plugin install wordpress-seo --path='cms' --url="$CLI_WEBSITE"
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
