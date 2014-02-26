#!/bin/bash -x
# Import variables from envoirnment.sh and user-variables.sh
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$current_dir"'/envoirnment.sh'
source "$current_dir"'/user-variables.sh'

echo ${wordpress_multisite_list[0]}
for i in "${wordpress_single_list[@]}"
do
  echo $i
done
for i in "${static_website_list[@]}"
do
  echo $i
done
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

