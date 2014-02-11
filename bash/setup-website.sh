#!/bin/bash
# Call script with ./setup-website.sh [multiple|static|wp_single|wp_multi] [site_name]

# Script parameters converted into variables
install_type="$1"
site_name="$2"

# Imports user-defined variables if a "multiple" installation is selected - possibility of creating super easy input method use http://stackoverflow.com/questions/16487258/how-to-declare-2d-array-in-bash
if $install_type = 'multiple'
    default_theme=( 'https://github.com/MByteIO/AnotherTheme.git' '' '' '' )
    declare -a site_list=( 'thebestsites.com' 'ultrasound.io' 'enviedsolutions.com' 'bestmetroapps.com' )
    declare -a wp_site_options=( '1 0 1' '1 0 0' '0 0 0' '1 1 1' )
    declare -a inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' 'front-end-editor' )
    declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )
    declare -a mu_git=( 'https://github.com/MByteIO/Must-Use-WordPress.git' )
fi

# Envoirnment specific variables
nginx_conf_dir='/usr/local/nginx'                               # Directory of nginx install file
source_dir='/usr/local/src'                                     # Directory of the MegabyteIO folder
nginx_conf="$nginx_conf_dir/nginx.conf"                         # nginx.conf location
site_conf_dir="$nginx_conf_dir/conf.d"                          # Site-specific conf location
website_dir='/home/nginx/domains'                               # Directory website files are kept in
current_dir="$( cd "$( dirname "${[0]}" )" && pwd )"            # Current directory (works unless script is symlinked) - see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

# Connection specific variables
mysql_host='localhost'                                          # Host of the MySQL database
declare -a requires_database=( 'wp-single' 'wp_multi' )         # Types of installations that need databases

# Site specific variables
site_conf="$site_conf_dir/$site_name.conf"                      # Site-specific configuration named [site_url].conf in the $site_conf_dir
declare -a site_folders=( 'public' 'private' 'logs' 'backup' )  # Folders to create for each website install
site_public="$website_dir/$site_name/public"                    # Public folder handle
site_private="$website_dir/$site_name/private"                  # Private folder handle
site_logs="$website_dir/$site_name/logs"                        # Log folder handle
site_backup="$website_dir/$site_name/backup"                    # Backup folder handle

# WordPress specific variables
wp_config=""                                                    # WordPress configuration file location
wp_core_folder=""                                               # Location of the WordPress core files

# CentminMod variables
centmin_dl_url='http://centminmod.com/download/'                # Remote directory containing Centmin file
centmin_filename='centmin-v1.2.3-eva2000.04.zip'                # Centmin zip file
centmin_dir="$source_dir/centmin-v1.2.3mod"                     # Centmin unzipped directory

# MegabyteIO specific directory structure
megabyteio_dir="$source_dir/megabyteio"                         # MegabyteIO directory
megabyteio_bash="$megabyteio_dir/bash"                          # MegabyteIO bash scripts sub-directory
megabyteio_expect="$megabyteio_dir/expect"                      # MegabyteIO expect scripts sub-directory
megabyteio_php="$megabyteio_dir/php"                            # MegabyteIO php scripts sub-directory
megabyteio_repos="$megabyteio_dir/modules"                      # MegabyteIO git sub-modules
megabyteio_confs="$megabyteio_dir/confs"                        # MegabyteIO configuration files
megabyteio_misc="$megabyteio_dir/misc"                          # MegabyteIO miscellaneous files

# Random variables for installs requiring a database
# Apply: http://stackoverflow.com/questions/3685970/bash-check-if-an-array-contains-a-value to see if install type needs db
if SomethingHereThenRunWordPressInstall

# Random variables for installs requiring a database
db_name=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
db_user=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
db_prefix=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
db_pass=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')

# Creates database using stored mysql password (or passed?)
mysql -uroot -p$mysql_root --verbose -e "CREATE DATABASE $site_name; GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'$mysql_host' IDENTIFIED BY '$db_pass'; FLUSH PRIVILEGES"

# Sets up the wp-config.php file
cp $megabyteio_confs/wp-config.php $wp_config
sed -i "s/{{DATABASE-NAME}}/$db_name/g" $wp_config
sed -i "s/{{DATABASE-USER-NAME}}/$db_user/g" $wp_config
sed -i "s/{{DATABASE-USER-PASSWORD}}/$db_pass/g" $wp_config
sed -i "s/{{DATABASE-TABLE-PREFIX/$db_prefix/g" $wp_config
sed -i "s/{{DOMAIN-NAME}}/$site_name/g" $wp_config
perl -i -pe '
BEGIN {
$keysalts = qx(curl -sS https://api.wordpress.org/secret-key/1.1/salt)
}
s/{{AUTH-KEYS-SALTS}}/$keysalts/g
' $wp_config
fi
# if
#sed -i "s/{{BACKEND-PATH-HANDLE}}/$wp_core_folder/g" $wp_config

#git clone $GITHUB_URL # to theme folder
# Add conf to conf.d

blah=' TO BE CONTINUED
cp $megabyteio_misc/robots.txt $site_public
echo "* $(tput setaf 6)Adjusting index.php to point to custom WordPress directory$(tput sgr0)"
sed -i "s/BACKENDPATH/$CLI_BACKEND_PATH/g" /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/index.php
echo "* $(tput setaf 6)Adjusting nginx configuration for current website$(tput sgr0)"
sed -i "s/REPLACETHIS/$CLI_WEBSITE/g" /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf
sed -i "s/BACKENDPATH/$CLI_BACKEND_PATH/g" /$NGINX_CONF_DIR/conf.d/$CLI_WEBSITE.conf

echo "* $(tput setaf 6)Adding \"Silence is golden\" index.php file to all custom directories$(tput sgr0)"
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
