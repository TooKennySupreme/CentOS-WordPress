#!/bin/bash

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
centmin_filename='centmin-v1.2.3-eva2000.06.zip'                # Centmin zip file
centmin_dir="$source_dir/centmin-v1.2.3mod"                     # Centmin unzipped directory

# MegabyteIO specific directory structure
megabyteio_dir="$source_dir/megabyteio"                         # MegabyteIO directory
megabyteio_bash="$megabyteio_dir/bash"                          # MegabyteIO bash scripts sub-directory
megabyteio_expect="$megabyteio_dir/expect"                      # MegabyteIO expect scripts sub-directory
megabyteio_php="$megabyteio_dir/php"                            # MegabyteIO php scripts sub-directory
megabyteio_repos="$megabyteio_dir/modules"                      # MegabyteIO git sub-modules
megabyteio_confs="$megabyteio_dir/confs"                        # MegabyteIO configuration files
megabyteio_misc="$megabyteio_dir/misc"                          # MegabyteIO miscellaneous files
