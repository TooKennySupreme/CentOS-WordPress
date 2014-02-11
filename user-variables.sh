#!/bin/bash

# Defaults for all websites
default_cache='fastcgi'

# Website list
declare -a site_list=( 'thebestsites.com' 'ultrasound.io' 'enviedsolutions.com' 'bestmetroapps.com' 'megabyte.io' 'laurazalewski.com' )

# Defaults for WordPress installations
default_theme='https://github.com/MByteIO/TheDefaultThemeGit.git'
default_mu='https://github.com/MByteIO/MustUseWordPressGit.git'
declare -a default_inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' 'front-end-editor' )
declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )
