#!/bin/bash -x

# Declare script variables for future portability
CENTMIN_DIR='usr/local/src' # Directory where centmin is installed
INSTALL_FOLDER_NAME='gigabyteio' # Folder name for the scripts, stored next to the centminmod directory in CENTMINDIR
CONF_FOLDER='configs' # Name of folder in the GigabyteIO directory that holds the configuration files
SCRIPTS_FOLDER='scripts' # Name of folder in the GigabyteIO directory that holds scripts
WORDPRESS_FOLDER='wordpress' # Name of folder in the GigabyteIO directory that holds WordPress related files
SSH_PORT_NUMBER=8388 # SSH port used - NOTE: NOT WORKING - SSH PORT is hardcoded as 8388 - Any help guys? Commits? :)
CENTMIN_FOLDER_NAME='centmin-v1.2.3mod' # Name of centmin folder
CENTMIN_DOWNLOAD_URL='http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip' # Centmin download URL
CENTMIN_FILE_NAME='centmin-v1.2.3-eva2000.04.zip' # Centmin zip file name
GITHUB_URL='https://github.com/GigabyteIO/WordPress-Droplet.git' # GigabyteIO git repo
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains' # Path to website files folder
NGINX_CONF_DIR='usr/local/nginx/conf' # Path to nginx configurations

# Change root user password
passwd

# Set up new root username and password for security purposes
if [ $(id -u) -eq 0 ]; then
        read -p "Enter a new root username: " NEW_ROOT_USERNAME
        read -s -p "Enter the new root users password: " NEW_ROOT_PASSWORD
        egrep "^$NEW_ROOT_USERNAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$NEW_ROOT_USERNAME already exists!"
                exit 1
        else
                ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
                useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
                [ $? -eq 0 ] && echo "$NEW_ROOT_USERNAME has been added to the user list." || echo "Failed to add $NEW_ROOT_USERNAME to the user list."
        fi
else
        echo "You must be root to add a user to the system."
        exit 2
fi

# Add new root user to visudo list
echo "What upppp?"
echo $CENTMIN_DIR
echo $INSTALL_FOLDER_NAME
echo $SCRIPTS_FOLDER
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
chmod +x visudo.sh
./visudo.sh $NEW_ROOT_USERNAME
chmod 644 visudo.sh

# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key (y/n)? " SSH_CHOICE
case "$SSH_CHOICE" in
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "Invalid input.";;
esac

# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
        echo "Moving SSH key credentials from root user to new root user. The root user will no longer be able to connect via SSH."
        cp /root/.ssh/authorized_keys /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
        rm ~/.ssh/authorized_keys
        chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh
        chmod 700 /home/$NEW_ROOT_USERNAME/.ssh
        chown $NEW_ROOT_USERNAME:$NEW_ROOT_USERNAME /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
        chmod 600 /home/$NEW_ROOT_USERNAME/.ssh/authorized_keys
fi

# Tweak SSH settings for security
# Let CentminMod handle the changing of the port number so that there are no conflicts with the firewall
# perl -pi -e 's/#Port 22/Port $SSH_PORT_NUMBER/g' /etc/ssh/sshd_config
perl -pi -e 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
perl -pi -e 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "AllowUsers $NEW_ROOT_USERNAME" >> /etc/ssh/sshd_config

# Modifies sshd_config if an SSH key is being used instead of a password
if [ "$SSH_CHOICE" == "yes" ]; then
        perl -pi -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        # This probably doesn't do anything because it's supposedly just for SSH1 but let's change it anyway.
        perl -pi -e 's/#ServerKeyBits 1024/ServerKeyBits 2048/g' /etc/ssh/sshd_config
fi

# Download and set up CentminMod
cd /$CENTMIN_DIR
wget $CENTMIN_DOWNLOAD_URL
unzip $CENTMIN_FILE_NAME
rm $CENTMIN_FILE_NAME
echo "Spot 1"
cd $CENTMIN_FOLDER_NAME
echo "Spot 2"
# Change time zone
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/nginx centminmod/GigabyteIO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
chmod +x centmin.sh
