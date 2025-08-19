#!/bin/bash

# A simple script to create a new user with sudo privileges.
# This script must be run as root.

# --- Security Check ---
# Check if the script is being run with root privileges.
# The 'EUID' variable holds the effective user ID. Root's UID is 0.
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root. Please use 'sudo'."
    exit 1
fi

# --- User Input ---
# Prompt the user for the new username.
# The 'read' command waits for input and stores it in the 'username' variable.
read -p "Enter the username for the new user: " username

# --- Validation ---
# Check if the username is empty.
if [[ -z "$username" ]]; then
    echo "Error: Username cannot be empty. Exiting."
    exit 1
fi

# Check if a user with that name already exists.
# The 'id' command checks for a user; we use a silent redirection to check for success.
if id "$username" &>/dev/null; then
    echo "Error: User '$username' already exists. Exiting."
    exit 1
fi

# --- Main Logic ---
# 1. Create the new user.
#    -m: Creates the user's home directory (/home/$username).
#    -s /bin/bash: Sets the default shell to Bash.
echo "Creating user '$username'..."
useradd -m -s /bin/bash "$username"

# 2. Set the password for the new user.
#    The 'passwd' command prompts for a password and a confirmation.
echo "Setting password for '$username'..."
passwd "$username"

# 3. Add the user to the 'sudo' group.
#    On most Debian/Ubuntu-based systems, this group is 'sudo'.
#    On other systems like RHEL/CentOS, it might be 'wheel'.
#    -aG: Appends the user (-a) to the specified supplementary group (-G).
echo "Adding '$username' to the 'sudo' group..."
usermod -aG sudo "$username"

# --- Confirmation ---
# Display a success message.
echo "---------------------------------------------------"
echo "Success! User '$username' has been created with sudo privileges."
echo "You can now log in as this user and use 'sudo'."
echo "---------------------------------------------------"

exit 0
