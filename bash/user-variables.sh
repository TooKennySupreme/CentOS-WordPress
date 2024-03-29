#!/bin/bash
# NOTE: This file is removed at the end of the installation process so your passwords will only be visible in this file temporarily.

# New root password
root_password='rootpassword'

# Root user name and password
new_root_username='testroot'
new_root_password='testpassword'

# New SSH port
new_ssh_port='8388'

# Website lists
wordpress_multisite_url='megabyte.io' # Domain name of main website to be used to set up the multisite
wordpress_multisite_title='Megabyte I/O'
declare -a static_website_list=( 'ultrasound.io' 'enviedsolutions.com' )

# Defaults for WordPress installations
wordpress_username='testwordpress'
wordpress_password='testwordpress'
wordpress_email='brian@enviedsolutions.com'
default_theme='https://github.com/MByteIO/MegabyteIO-Theme.git'           # Default theme git
default_theme_folder_name='megabyteio'
default_mu='https://github.com/MByteIO/MegabyteIO-MustUse.git'            # Default must-use plugins git
declare -a inactive_plugins=( 'wordpress-seo' 'pods' 'redirection' 'w3-total-cache' )
