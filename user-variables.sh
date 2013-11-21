#!/bin/bash

default_type='static'
default_cache='fastcgi'
declare -a site_list=( 'thebestsites.com' 'ultrasound.io' 'enviedsolutions.com' 'bestmetroapps.com' )

# Defaults for WordPress installations
default_theme='https://github.com/MByteIO/AnotherTheme.git'
default_mu='https://github.com/MByteIO/Must-Use-WordPress.git'
declare -a default_inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' 'front-end-editor' )
declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )

# Specify cases where defaults should not be used
theme_overide( 'thebestsites.com', 'https://github.com/MByteIO/AnotherTheme.git' )
cache_overide( 'thebestsites.com', 'wp_single' )
