#!/bin/bash

# Usage: wordpress_install website
function custom_wordpress_install {
	# Set location variables
	public_folder="$website_dir""$1"'/public/'
	private_folder="$website_dir""$1"'/private/'
	backend_folder="$public_folder""$custom_backend"'/'
	wp_config="$public_folder"'wp-config.php'
	db_config="$private_folder"'db-config.php'

	# Remove base files from public folder and make folders
	rm -rf "$public_folder"*
	mkdir "$backend_folder"
	mkdir "$public_folder"'content'
	mkdir "$public_folder"'addons'
	mkdir "$public_folder"'includes'
	mkdir "$public_folder"'content/themes'

	# Add index files to directories
	cp "$php_dir"'index.php' "$public_folder"'content'
	cp "$php_dir"'index.php' "$public_folder"'addons'
	cp "$php_dir"'index.php' "$public_folder"'includes'
	cp "$php_dir"'index.php' "$public_folder"'content/themes'

	# Add public folder index
	cp "$php_dir"'public_index.php' "$public_folder"'index.php'
	sed -i "s/{CUSTOM_BACKEND}/$custom_backend/g" "$public_folder"'index.php'

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

	# Edit backend path in wp-config.php
	sed -i "s/{CUSTOM_BACKEND}/$custom_backend/g" "$wp_config"

	# Download WordPress core files
	wget -P "$backend_folder" 'http://wordpress.org/latest.tar.gz'
	tar -xzf "$backend_folder"'latest.tar.gz' -C "$backend_folder"
	cp -Rf "$backend_folder"'wordpress/'* "$backend_folder"
	rm -Rf "$backend_folder"'wordpress'
	rm -f "$backend_folder"'latest.tar.gz'
	rm -f "$backend_folder"'license.txt'
	rm -f "$backend_folder"'readme.html'
	rm -f "$backend_folder"'wp-config-sample.php'

	# Install WordPress
	cd "$public_folder"
	wp core install --path="$custom_backend" --url="$1" --title="$wordpress_multisite_title" --admin_user="$wordpress_username" --admin_password="$wordpress_password" --admin_email="$wordpress_email"

	# Install base theme
	git clone $default_theme "$public_folder"'content/themes'

	# Install default must-use plugins
	git clone $default_mu "$public_folder"'includes'

	# Install activated plugins
	for i in "${activate_plugins[@]}"
	do
		wp plugin install --activate $i --path="$custom_backend" --url="$1" --allow-root
	done

	# Install deactivated plugins
	for i in "${inactive_plugins[@]}"
	do
		wp plugin install $i --path="$custom_backend" --url="$1" --allow-root
	done

	# Set nginx as the owner for all files
	chown -Rf nginx:nginx "$public_folder"
}
