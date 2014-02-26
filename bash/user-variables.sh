#!/bin/bash

# New root password
root_password='rootpassword'

# Root user name and password
new_root_username='testroot'
new_root_password='testpassword'

# New SSH port
new_ssh_port='8388'

# API Keys
cloudflare_email=''
cloudflare_api_key=''
github_api_key=''

# Defaults for all websites
default_cache='fastcgi'

# Website lists
declare -a wordpress_multisite_list=( 'megabyte.io' 'bestwebapps.net' 'enviedsolutions.com' 'bestmetroapps.com' 'thebestsites.com' 'laurazalewski.com' 'ultrasound.io' ) # First website in list is the primary domain
declare -a wordpress_single_list=( 'laurazalewski.com' 'flya' )
declare -a static_website_list=( 'pharmasonic.net' 'hiya' )

# Defaults for WordPress installations
wordpress_username='testwordpress'
wordpress_password='testwordpress'
default_theme='https://github.com/MByteIO/SimpleAwesomeWordPress.git'       # Default theme git
default_mu='https://github.com/MByteIO/MustUseWordPress.git'                # Default must-use plugins git
declare -a default_inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' 'front-end-editor' )
declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )
