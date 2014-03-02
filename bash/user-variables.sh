#!/bin/bash

# New root password
root_password='rootpassword'

# Root user name and password
new_root_username='testroot'
new_root_password='testpassword'

# New SSH port
new_ssh_port='8388'

# Website lists
declare -a wordpress_multisite_list=( 'megabyte.io' 'bestmetroapps.com' 'thebestsites.com' 'laurazalewski.com' ) # First website in list is the primary domain
declare -a wordpress_multisite_titles=( 'Megabyte I/O' 'Best Metro Apps' 'The Best Sites' 'Laura Zalewski' )
declare -a static_website_list=( 'ultrasound.io' 'enviedsolutions.com' )

# Defaults for WordPress installations
wordpress_username='testwordpress'
wordpress_password='testwordpress'
wordpress_email='brian@enviedsolutions.com'
custom_backend='cms'                                                        # Custom backend path
default_theme='https://github.com/MByteIO/MegabyteIO-Theme.git'             # Default theme git
default_mu='https://github.com/MByteIO/MegabyteIO-MustUse.git'                # Default must-use plugins git
declare -a active_plugins=( 'google-sitemap-generator' 'redirection' )
declare -a inactive_plugins=( 'wordpress-seo' 'pods' 'my-shortcodes' )
