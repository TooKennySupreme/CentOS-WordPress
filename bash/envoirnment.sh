#!/bin/bash

# Envoirnment specific variables
nginx_conf_dir='/usr/local/nginx/'                               # Directory of nginx install file
source_dir='/usr/local/src/'                                     # Directory of the MegabyteIO folder
nginx_conf="$nginx_conf_dir"'nginx.conf'                         # nginx.conf location
site_conf_dir="$nginx_conf_dir"'conf.d/'                         # Site-specific conf location
website_dir='/home/nginx/domains/'                               # Directory website files are kept in
ssh_conf='/etc/ssh/sshd_config'                                  # SSH configuration file

# Connection specific variables
mysql_host='localhost'                                           # Host of the MySQL database
mysql_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c32 | tr -d '-') # MySQL root password
client_ip_address=$(echo $SSH_CONNECTION | cut -f1 -d' ')	 # Connecting clients IP address
server_ip_address=$(echo $SSH_CONNECTION | cut -f3 -d' ')	 # Servers IP address

# CentminMod variables
centmin_dl_url='http://centminmod.com/download/'                 # Remote directory containing Centmin file
centmin_filename='centmin-v1.2.3-eva2000.06.zip'                 # Centmin zip file
centmin_dir="$source_dir"'centmin-v1.2.3mod/'			 # Centmin unzipped directory
centmin_setup="$centmin_dir"'centmin.sh'			 # Centmin.sh location
centmin_addons="$centmin_dir"'addons/'				 # Centmin addons directory
centmin_wpcli="$centmin_addons"'wpcli.sh'			 # Centmin wpcli.sh location

# MegabyteIO specific directory structure
megabyteio_dir="$source_dir"'megabyteio/'                         # MegabyteIO directory
declare -a megabyteio_folders=( 'bash' 'expect' 'php' 'confs' 'misc' )
for i in "${megabyteio_folders[@]}"			         # Create folder directory variables from megabyteio_folders	  
do
	current_variable="$i"'_dir'
	declare $current_variable=""$megabyteio_dir""$i"/"
done

# Misc
memcached_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c16 | tr -d '-') # Memcached password
