# Linux User Creation Bash Script

## Description
A bash script called create_users.sh that reads a text file containing the employee’s usernames and group names, where each line is formatted as `user;groups`.

## Running the command
Before you run the command `bash create_users.sh <name-of-text-file>` make sure you have created a file `<name-of-text-file>.txt` which should contain set of users and the groups you want to create. See example below:

```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```

Now run the script with example below (if you created text file as `users.txt`)

```bash
$ bash create_users.sh users.txt
```

Make sure you are `root` when running the script, to get full access and permissions

## Things to note for your text file
* Each User must have a unique username, different from another user
* A user can have multiple groups, each group delimited by comma ","
* Usernames and user groups are separated by semicolon ";" - `No whitespace`

## After running script
* All users will be created by username and are assigned to their own group and the groups specified
* A file `/var/log/user_management.log` is created where all logs are shown based on actions performed on the script
* A file `/var/secure/user_passwords.txt` is created on each users `home/<username>/` directory where thier passwords are stored.