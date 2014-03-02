#!/bin/bash -x
# Import variables from envoirnment.sh and user-variables.sh
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$current_dir"'/envoirnment.sh'
source "$current_dir"'/user-variables.sh'

# Install dependencies
yum -y install expect git wget unzip bc yum-plugin-fastestmirror
yum clean all

# Change the root password (supplied in user_variables.sh)
echo -e "$root_password\n$root_password" | (passwd --stdin $USER)

# Set up new root user and root password
adduser $new_root_username
echo -e "$new_root_password\n$new_root_password" | (passwd $new_root_username --stdin)
echo "$new_root_username ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/root_users;

# Set memcached password to random password
memcached_password=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c16 | tr -d '-')

# Collect IP information
ssh_client_ip_address=$(echo $SSH_CONNECTION | cut -f1 -d' ')
ssh_server_ip_address=$(echo $SSH_CONNECTION | cut -f3 -d' ')
ip_address=$(curl -silent ifconfig.me)

# Update system
yum -y --exclude=kernel* --exclude=setup* update

# Tweak SSH settings for security
perl -pi -e 's/#UseDNS yes/UseDNS no/g' $ssh_conf
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' $ssh_conf
echo "AllowUsers $new_root_username" >> $ssh_conf

# Download and set up CentminMod directory
wget -P "$source_dir" "$centmin_dl_url$centmin_filename"
unzip "$source_dir$centmin_filename" -d "$source_dir"
rm "$source_dir$centmin_filename"

# Change time zone in centmin.sh
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' "$centmin_setup"
perl -pi -e 's/Brisbane/New_York/g' "$centmin_setup"

# Change custom TCP packet header in centmin.sh
perl -pi -e 's/nginx centminmod/MegabyteIO/g' "$centmin_setup"

# Run the Centmin Mod installation
chmod +x "$expect_dir"'centmin-install.exp'
chmod +x "$centmin_setup"
cd "$centmin_dir"
"$expect_dir"'centmin-install.exp' "$root_password" 'memcached' "$memcached_password" "$centmin_setup"

# Change SSH port to new port designated in user-variables.sh
chmod +x "$expect_dir"'centmin-ssh.exp'
"$expect_dir"'centmin-ssh.exp' '22' "$new_ssh_port" "$centmin_setup"

# Setup multisite vhost and directory
"$expect_dir"'centmin-website.exp' "${wordpress_multisite_list[0]}"

# Setup static websites vhosts and directories
for i in "${static_website_list[@]}"
do
  "$expect_dir"'centmin-website.exp' "$i"
done

# Disable APC CLI in both the apc.ini file and the php.ini file
perl -pi -e 's/apc.enable_cli=1/apc.enable_cli=0/g' /root/centminmod/php.d/apc.ini
echo "apc.enable_cli = Off" >> /usr/local/lib/php.ini

# Changes shm_size to 256M - What's the optimal shm_size? Any ideas?
perl -pi -e 's/apc.shm_size=32M/apc.shm_size=256M/g' /root/centminmod/php.d/apc.ini

# Install WP-CLI
curl https://raw.github.com/wp-cli/wp-cli.github.com/master/installer.sh | bash
echo 'export PATH=/root/.wp-cli/bin:$PATH' >> ~/.bash_profile

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
