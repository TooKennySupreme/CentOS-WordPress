#!/bin/bash

# Usage: wordpress_install website
function custom_wordpress_install {
	# Set location variables
	public_folder="$website_dir""$1"'/public/'
	private_folder="$website_dir""$1"'/private/'

	# Remove base files
	rm -rf "$public_folder"*

	# Add robots.txt
	cp "$misc_dir"'robots.txt' "$public_folder"

	# Generate random MySQL credentials and random table prefix
	database_name=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	database_user=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	random_prefix=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
	database_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')

	# Create database
	mysql -uroot -p"$mysql_password" --verbose -e "CREATE DATABASE $database_name; GRANT ALL PRIVILEGES ON $database_name.* TO '$database_user'@'$mysql_host' IDENTIFIED BY '$database_password'; FLUSH PRIVILEGES"
  	
  	# Copy multisite template
	cp "$php_dir"'wp-mu-config.php' "$wp_config"

	# Edit connection settings in wp-config.php
	sed -i "s/{DATABASE_NAME}/$database_name/g" "$wp_config"
	sed -i "s/{DATABASE_USER}/$database_user/g" "$wp_config"
	sed -i "s/{DATABASE_PASSWORD}/$database_password/g" "$wp_config"
	sed -i "s/{DATABASE_PREFIX}/$random_prefix/g" "$wp_config"

	# Edit Salts in wp-config.php
	perl -i -pe 'BEGIN {$keysalts = qx(curl -sS https://api.wordpress.org/secret-key/1.1/salt)} s/{AUTH-KEYS-SALTS}/$keysalts/g' "$wp_config"

	# Edit default theme folder name in wp-config.php
	sed -i "s/{DEFAULT_THEME}/$default_theme_folder_name/g" "$wp_config"
	
	# Add website name for php log
	sed -i "s/{WEBSITE_NAME}/$1/g" "$wp_config"
	
	# Download WordPress core files
	cd "$public_folder"
	wp core download --allow-root
	rm -f "$public_folder"'latest.tar.gz'
	rm -f "$public_folder"'license.txt'
	rm -f "$public_folder"'readme.html'
	rm -f "$public_folder"'wp-config-sample.php'
	
	# Add must-use-plugins and default theme
	git clone $default_theme "$public_folder"'wp-content/themes/'"$default_theme_folder_name"
	git clone $default_mu "$public_folder"'wp-content/mu-plugins'

	# Install WordPress
	wp core multisite-install --url="$1" --subdomains --title="$wordpress_multisite_title" --admin_user="$wordpress_username" --admin_password="$wordpress_password" --admin_email="$wordpress_email" --allow-root

	# Install deactivated plugins
	for i in "${inactive_plugins[@]}"
	do
		wp plugin install $i --allow-root
	done
	
	# Set nginx as the owner for all files
	chown -Rf nginx:nginx "$public_folder"
}
