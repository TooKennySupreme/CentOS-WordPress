#!/bin/bash

# Defaults for all websites
default_cache='fastcgi'

# Website lists
declare -a wordpress_multisite_list=( 'thebestsites.com' 'ultrasound.io' 'enviedsolutions.com' 'bestmetroapps.com' 'megabyte.io' 'laurazalewski.com' )

# Defaults for WordPress installations
default_theme='https://github.com/MByteIO/SimpleAwesomeWordPress.git'
default_mu='https://github.com/MByteIO/MustUseWordPress.git'
declare -a default_inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' 'front-end-editor' )
declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )
