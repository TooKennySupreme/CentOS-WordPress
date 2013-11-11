#!/bin/bash -x

# Setting time zone has to be done manually for now - not exactly sure how to find and replace with a variable - if anyone could guide me in the right direction, I'll add this feature :)
# Declare script variables for future portability
CENTMIN_DIR='usr/local/src' # Directory where centmin is installed
INSTALL_FOLDER_NAME='gigabyteio' # Folder name for the scripts, stored next to the centminmod directory in CENTMINDIR
CONF_FOLDER='configs' # Name of folder in the GigabyteIO directory that holds the configuration files
SCRIPTS_FOLDER='scripts' # Name of folder in the GigabyteIO directory that holds scripts
WORDPRESS_FOLDER='wordpress' # Name of folder in the GigabyteIO directory that holds WordPress related files
SSH_PORT_NUMBER=8388 # SSH port used, this is changed automatically after the Centmin install finishes
CENTMIN_FOLDER_NAME='centmin-v1.2.3mod' # Name of centmin folder
CENTMIN_DOWNLOAD_URL='http://centminmod.com/download/centmin-v1.2.3-eva2000.04.zip' # Centmin download URL
CENTMIN_FILE_NAME='centmin-v1.2.3-eva2000.04.zip' # Centmin zip file name
GITHUB_URL='https://github.com/GigabyteIO/WordPress-Droplet.git' # GigabyteIO git repo
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains' # Path to website files folder
NGINX_CONF_DIR='usr/local/nginx/conf' # Path to nginx configurations

# Change root user password
echo ""
echo ""
echo "TASKS COMPLETED SO FAR:"
echo "- System has been updated to latest software."
echo "- Some dependencies have been installed (bc and git)."
echo "- GigabyteIO has been cloned to /usr/local/src/gigabyteio."
echo ""
echo "NOTE:"
echo "Begin by changing the root password. After the installation, there will be no reason to use the root user. We will instead execute root commands using a different user account with root privileges. You should make this root password long and very hard to guess."
echo ""
passwd
echo ""
echo "NOTE:"
echo "Now create a new user and password combination. This is the user that you will use when doing anything that requires root privileges. When doing something that requires root privileges with this new user, you will have to add 'sudo' to the beginning of the command."

# Set up new root username and password for security purposes
if [ $(id -u) -eq 0 ]; then
        read -p "Enter a new root username: " NEW_ROOT_USERNAME
        read -s -p "Enter the new root users password: " NEW_ROOT_PASSWORD
        egrep "^$NEW_ROOT_USERNAME" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "" && echo "" && echo "$NEW_ROOT_USERNAME already exists!"
                exit 1
        else
                ENCRYPTED_NEW_ROOT_PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $NEW_ROOT_PASSWORD)
                useradd -m -p $ENCRYPTED_NEW_ROOT_PASSWORD $NEW_ROOT_USERNAME
                [ $? -eq 0 ] && echo "" && echo "" && echo "$NEW_ROOT_USERNAME has been added to the user list." || echo "" && echo "" && echo "Failed to add $NEW_ROOT_USERNAME to the user list."
        fi
else
        echo "" && echo "" && echo "You must be root to add a user to the system."
        exit 2
fi
# Add new root user to visudo list
cd /$CENTMIN_DIR/$INSTALL_FOLDER_NAME/$SCRIPTS_FOLDER
chmod +x visudo.sh
./visudo.sh $NEW_ROOT_USERNAME
chmod 644 visudo.sh
echo ""
echo "NOTE:"
echo "It is highly recommended to log into your server with an SSH key. This will encrypt all data communications (preventing clear text passwords), make it much harder for hackers to target you, and allow you to login to your server without typing your username or password. With Digital Ocean, you can create a server with an SSH key system already implemented. By answering yes to the following prompt, password authentication will be disabled and it will only be possible to log in to your server with an SSH key. The login credentials will also be transferred from the root user to the new root user we just created."
echo ""
# Change the SSH key to be used with new root user
read -p "Is this a Digital Ocean droplet created using an SSH key (y/n)? " SSH_CHOICE
case "$SSH_CHOICE" in
  y|Y ) echo "yes";;
  n|N ) echo "no";;
  * ) echo "Invalid input.";;
esac

# Transfer SSH key credentials from root to new root user
if [ "$SSH_CHOICE" == "yes" ]; then
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

# Download and set up CentminMod directory
cd /$CENTMIN_DIR
wget $CENTMIN_DOWNLOAD_URL
unzip $CENTMIN_FILE_NAME
rm $CENTMIN_FILE_NAME
cd $CENTMIN_FOLDER_NAME

# Change time zone in centmin.sh
perl -pi -e 's/ZONEINFO=Australia/ZONEINFO=America/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
perl -pi -e 's/Brisbane/New_York/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change custom TCP packet header in centmin.sh
perl -pi -e 's/nginx centminmod/GigabyteIO/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change permissions of centmin.sh to executable
chmod +x centmin.sh

# Disable the menu system in centmin.sh
perl -pi -e '/ENABLE_MENU=.y./ && s/y/n/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
echo ""
echo "NOTE:"
echo "The initial set up is complete. Now, if you restart the server or attempt to log in via SSH, you will only be able to connect via the server's IP address on port number 8388 (please note that the port number is changed at the end of the installation so if the script fails for whatever reason, the SSH port might still be 22). In addition, the only user that can login is your new root username. If for some reason you need to use the root user, you will have to login with your new root username and then switch to the root user by entering 'su'.\n\nThe script will now compile the server via CentminMod. This process generally takes around 20 minutes. For the most part, it is an unattended installation."
echo ""
read -p "Press enter to continue: " CONTINUE_PROMPT
# Install CentminMod
./centmin.sh install
read -p "Centmin Install done. Ready to change the SSH port?: " RANDOMTHINGHERE
# Change SSH port
cp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup
perl -pi -e 's/read -ep "Enter existing SSH port number \(default = 22 for fresh installs\): " EXISTPORTNUM/EXISTPORTNUM=22/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
echo $SSH_PORT_NUMBER | ./centmin.sh sshdport

# Restore centmin SSH config file to original state
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
cp /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd.inc
rm -f /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/inc/sshd-backup

# Restore centmin.sh menu system (to keep centmin.sh in original condition
# NOTE: Substitute (find and replace) "foo" with "bar" on lines that match "baz"
# NOTE: perl -pe '/baz/ && s/foo/bar/'
# NOTE: See http://www.catonmat.net/download/perl1line.txt for more tricks
perl -pe '/ENABLE_MENU=.n./ && s/n/y/g' /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh

# Change permissions of centmin.sh back to original
chmod 644 /$CENTMIN_DIR/$CENTMIN_FOLDER_NAME/centmin.sh
