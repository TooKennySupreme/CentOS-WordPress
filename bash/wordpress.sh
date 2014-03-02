#!/bin/bash

# Usage: wordpress_install website
function custom_wordpress_install {
	# Set location variables
	public_folder="$website_dir""$1"'/public/'
	private_folder="$website_dir""$1"'/private/'
	wp_config="$public_folder"'wp-config.php'
	db_config="$private_folder"'db-config.php'

	# Remove base files from public folder and make custom backend folder
	rm -rf "$public_folder"'*'
	mkdir "$public_folder""$custom_backend"

	# Generate random MySQL credentials and random table prefix
	database_name=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	database_user=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
	random_prefix=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
	database_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')

	# Create database
	mysql -uroot -p"$mysql_password" --verbose -e "CREATE DATABASE $database_name; GRANT ALL PRIVILEGES ON $database_name.* TO '$database_user'@'$database_host' IDENTIFIED BY '$database_password'; FLUSH PRIVILEGES"
  	
  	# Copy multisite template
	cp "$php_dir"'wp-mu-config.php' "$wp_config"

	# Edit connection settings in wp-config.php
	sed -i "s/{DATABASE_NAME}/$database_name/g" "$wp_config"
	sed -i "s/{DATABASE_USER}/$database_user/g" "$wp_config"
	sed -i "s/{DATABASE_PASSWORD}/$database_password/g" "$wp_config"
	sed -i "s/{DATABASE_PREFIX}/$random_prefix/g" "$wp_config"

	# Edit Salts in wp-config.php
	perl -i -pe 'BEGIN {$keysalts = qx(curl -sS https://api.wordpress.org/secret-key/1.1/salt)} s/{AUTH-KEYS-SALTS}/$keysalts/g' "$wp_config"

	# Edit backend path in wp-config.php
	sed -i "s/{CUSTOM_BACKEND}/$custom_backend/g" "$wp_config"
}
