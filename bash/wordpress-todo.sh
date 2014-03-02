#!/bin/bash

#echo "* $(tput setaf 6)Cloning batcache plugin$(tput sgr0)"
#git clone -q https://github.com/Automattic/batcache.git
#echo "* $(tput setaf 6)Cloning APC cache plugin$(tput sgr0)"
#git clone -q https://github.com/eremedia/APC.git

# Move caching plugin files to appropriate directories
#echo "* $(tput setaf 6)Installing batcache to appropriate folders$(tput sgr0)"
#cp /$POOR_IO_HOME/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
#cp /$POOR_IO_HOME/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/addons/batcache.php
#echo "* $(tput setaf 6)Installing APC object-cache plugin to appropriate folder$(tput sgr0)"
#cp /$POOR_IO_HOME/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php


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

service nginx restart
