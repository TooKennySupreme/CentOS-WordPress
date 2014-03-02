#!/bin/bash -x
# Import variables from envoirnment.sh and user-variables.sh
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$current_dir"'/envoirnment.sh'
source "$current_dir"'/user-variables.sh'
source "$current_dir"'/wordpress-install.sh'

# Install dependencies, update system, and clean all
yum -y install expect git wget unzip bc yum-plugin-fastestmirror
yum -y --exclude=kernel* --exclude=setup* update
yum clean all

# Change the root password (supplied in user_variables.sh)
echo -e "$root_password\n$root_password" | (passwd root --stdin)

# Set up new root user and root password (supplied in user_variables.sh)
adduser $new_root_username
echo -e "$new_root_password\n$new_root_password" | (passwd $new_root_username --stdin)
echo "$new_root_username ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/root_users;

# Transfer authorized_keys from root to new root user
mkdir /home/$new_root_username/.ssh
cp /root/.ssh/authorized_keys /home/$new_root_username/.ssh/authorized_keys
rm /root/.ssh/authorized_keys
chown $new_root_username:$new_root_username /home/$new_root_username/.ssh
chmod 700 /home/$new_root_username/.ssh
chown $new_root_username:$new_root_username /home/$new_root_username/.ssh/authorized_keys
chmod 600 /home/$new_root_username/.ssh/authorized_keys

# Tweak SSH settings for security
perl -pi -e 's/#UseDNS yes/UseDNS no/g' $ssh_conf
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' $ssh_conf
echo "AllowUsers $new_root_username'@'$client_ip_address" >> $ssh_conf

# Download and set up CentminMod directory
wget -P "$source_dir" "$centmin_dl_url$centmin_filename"
unzip "$source_dir$centmin_filename" -d "$source_dir"
rm "$source_dir$centmin_filename"

# Change time zone in centmin.sh
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' "$centmin_setup"
perl -pi -e 's/Brisbane/New_York/g' "$centmin_setup"

# Change custom TCP packet header in centmin.sh
perl -pi -e 's/nginx centminmod/MegabyteIO/g' "$centmin_setup"

# Set script permissions to executable
chmod +x "$centmin_setup"
chmod +x "$centmin_wpcli"
chmod +x "$expect_dir"'*'

# Run the Centmin Mod installation
cd "$centmin_dir"
"$expect_dir"'centmin-install.exp' "$mysql_password" "$new_root_username" "$memcached_password" "$centmin_setup"

# Change SSH port to new port designated in user-variables.sh
"$expect_dir"'centmin-ssh.exp' '22' "$new_ssh_port" "$centmin_setup"

# Setup multisite vhost and directory
"$expect_dir"'centmin-website.exp' "${wordpress_multisite_list[0]}"

# Setup static websites vhosts and directories
for i in "${static_website_list[@]}"
do
  "$expect_dir"'centmin-website.exp' "$i"
done

# Install WP-CLI
"$centmin_wpcli"' install --allow-root'

# Install WordPress multi-site
custom_wordpress_install "${wordpress_multisite_list[0]}"

# Disable APC CLI in both the apc.ini file and the php.ini file
perl -pi -e 's/apc.enable_cli=1/apc.enable_cli=0/g' /root/centminmod/php.d/apc.ini
echo "apc.enable_cli = Off" >> /usr/local/lib/php.ini

# Changes shm_size to 256M - What's the optimal shm_size? Any ideas?
perl -pi -e 's/apc.shm_size=32M/apc.shm_size=256M/g' /root/centminmod/php.d/apc.ini

# Save passwords to root folder in file named .passwords
echo 'mysql_root_password='"$mysql_password" >> '/root/.passwords'
echo 'memcached_password='"$memcached_password" >> '/root/.passwords'

# Reset permissions on executable files
chmod 644 "$centmin_setup"
chmod 644 "$centmin_wpcli"
chmod 644 "$expect_dir"'*'

# Credits and further instructions
echo ""
echo ""
echo "$(tput bold)$(tput setaf 2)Installation Complete$(tput sgr0)"
echo ""
echo "$(tput bold)$(tput setaf 6)Thanks for choosing CentOS WordPress$(tput sgr0)"
echo "Home URL  : http://megabyte.io"
echo "Github URL: https://github.com/MByteIO/CentOS-WordPress"
echo "Author    : Brian Zalewski"
echo "Credit to CentminMod! Check out their website at http://centminmod.com/!"
echo ""
echo ""
