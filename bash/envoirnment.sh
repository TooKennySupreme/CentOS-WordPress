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
declare -a requires_database=( 'wp-single' 'wp_multi' )          # Types of installations that need databases

# Site specific variables
site_conf="$site_conf_dir"'$site_name.conf'                      # Site-specific configuration named [site_url].conf in the $site_conf_dir
declare -a site_folders=( 'public' 'private' 'logs' 'backup' )   # Folders to create for each website install

# WordPress specific variables
wp_config=""                                                     # WordPress configuration file location
wp_core_folder=""                                                # Location of the WordPress core files

# CentminMod variables
centmin_dl_url='http://centminmod.com/download/'                 # Remote directory containing Centmin file
centmin_filename='centmin-v1.2.3-eva2000.06.zip'                 # Centmin zip file
centmin_dir="$source_dir"'centmin-v1.2.3mod/'			 # Centmin unzipped directory

# MegabyteIO specific directory structure
megabyteio_dir="$source_dir"'megabyteio/'                         # MegabyteIO directory
declare -a megabyteio_folders=( 'bash' 'expect' 'php' 'modules' 'confs' 'misc' )
for i in "${megabyteio_folders[@]}"			         # Create folder directory variables from megabyteio_folders	  
do
	declare "$i_dir="$megabyteio_dir""$i"/"
	echo $i_dir
done
