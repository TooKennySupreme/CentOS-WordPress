#!/bin/bash -x
current_dir="/usr/local/src/megabyteio/bash"
source $current_dir/envoirnment.sh
source $current_dir/user-variables.sh

# Install dependencies
yum -y install expect git wget unzip bc

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
# yum -y --exclude=kernel* --exclude=setup* update

# Tweak SSH settings for security
perl -pi -e 's/#UseDNS yes/UseDNS no/g' $ssh_conf
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' $ssh_conf
echo "AllowUsers $new_root_username" >> $ssh_conf

# Download and set up CentminMod directory
wget -P "$source_dir" "$centmin_dl_url/$centmin_file_name"
unzip "$source_dir/$centmin_file_name"
rm "$source_dir/$centmin_file_name"

# Change time zone in centmin.sh
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' $centmin_dir/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' $centmin_dir/centmin.sh

# Change custom TCP packet header in centmin.sh
perl -pi -e 's/nginx centminmod/MegabyteIO/g' /$centmin_dir/centmin.sh
