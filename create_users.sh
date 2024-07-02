#!/bin/bash

# Check if user is root to get full access and permissions
if [[ $(whoami) != "root" ]]; then
    echo "Error: needs root access, kindly switch to 'root' using command >> sudo su root"
    exit 1
fi

# Read the command line arguments, args
ARGS=("$@")

# Check if first argument is passed
if [[ ${ARGS[0]} == "" ]]; then
echo "Error: requires at least one arg to be passed, e.g bash create_user.sh <name-of-text-file>"
exit 1
fi

# Define vairable for FILE
FILE=${ARGS[0]}

# Check if file exists
if [ ! -f $FILE ]
then
    echo "Error: file does not exists"
    exit 1
fi

# Check if file type is text/plain
if [[ ${FILE##*.} != "txt" && "$(file -b --mime-type "$FILE")" != "text/plain" ]]
then
  echo "Error: required file type is text"
  exit 1
fi

create_file_in_directory() {
    sudo mkdir -p $(dirname $1) && sudo touch $*
    echo "File and path created: $*"
}

# Create log file
log_path=/var/log/user_management.log

create_file_in_directory $log_path

# Create users data file
user_data_path=var/secure/user_passwords.txt

log() {
    sudo printf "$*\n" >> $log_path
}

save_user_data() {
    sudo printf "$1,$2\n" >> $3
}

gen_random_password() {
    < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12
}

create_user() {
    username=$1
    password=$(gen_random_password)

    # If username exists, do nothing
    if [ ! $(cat /etc/passwd | grep -w $username) ]; then
        # Create the user with the specified username
        # User is created with a group as their name
        sudo useradd -m -s /bin/bash $username

        # Set the user's password
        echo "$username:$password" | sudo chpasswd
        msg="User '$username' created with the password '*******'"
        echo $msg
        log $msg

        # Save user data
        dir=/home/$username/$user_data_path

        create_file_in_directory $dir

        save_user_data $username $password $dir
        
        # Set file group to user and give read only acces
        sudo chgrp $username $dir
        sudo chmod 040 $dir
    fi
}

create_group() {
    # Create group
    # If group exists, do nothing
    if [ ! $(cat /etc/group | grep -w $1) ]; then
        sudo groupadd $1
        msg="Group created '$1'"
        echo $msg
        log $msg
    fi
}

add_user_to_group() {
    #  Add user to group
   sudo usermod -aG $2 $1
   msg="'$1' added to '$2'"
   echo $msg
   log $msg
}

# Read the FILE
while IFS= read -r line || [ -n "$line" ]; 
do

# Assign variable for <user>
username=$(printf "%s" "$line"| cut -d \; -f 1)

# Assign variable for <groups>
usergroups=$(printf "%s" "$line"| cut -d \; -f 2)

echo "----- Start process for: '$username' -----"

# Create user
create_user $username

# Create user groups
for group in ${usergroups//,/ } ; do 
    create_group $group
    add_user_to_group $username $group
done

echo "----- Done with '$username' -----"
echo ""
done < $FILE
