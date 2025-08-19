#!/bin/bash

# ==============================================================================
# Script: disable_ipv6.sh
# Description: Permanently disables IPv6 on Ubuntu systems.
# Date: October 26, 2023
#
# USAGE:
#   1. Save this script as disable_ipv6.sh
#   2. Make it executable: chmod +x disable_ipv6.sh
#   3. Run with superuser privileges: sudo ./disable_ipv6.sh
# ==============================================================================

# --- Safety Check: Ensure the script is run as root ---
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo." >&2
  exit 1
fi

# --- Define the sysctl configuration file ---
# Using /etc/sysctl.d/ is the modern and clean way to add kernel parameters.
SYSCTL_CONF="/etc/sysctl.d/99-disable-ipv6.conf"

echo "--- Starting IPv6 Disablement Process ---"

# --- Step 1: Create the sysctl configuration file to disable IPv6 ---
echo "Creating sysctl configuration at $SYSCTL_CONF..."

# Using a 'here document' to write the configuration.
# This disables IPv6 on all current and future interfaces.
cat > "$SYSCTL_CONF" <<EOF
# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Check if the file was created successfully
if [ ! -f "$SYSCTL_CONF" ]; then
    echo "Error: Could not create $SYSCTL_CONF. Aborting." >&2
    exit 1
fi

echo "Configuration file created successfully."

# --- Step 2: Apply the sysctl settings immediately ---
echo "Applying sysctl settings to the running system..."
sysctl -p > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Warning: There was an issue applying the sysctl settings."
    echo "A reboot will be required to apply them."
else
    echo "Sysctl settings applied."
fi

# --- Step 3: (Optional but recommended) Update /etc/hosts ---
# This prevents some applications from trying to resolve 'localhost' to '::1'
HOSTS_FILE="/etc/hosts"
echo "Updating $HOSTS_FILE to comment out IPv6 localhost entry..."

# Create a backup of the hosts file before modifying it
cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"

# Use sed to comment out the line that starts with '::1'
# The -i flag edits the file in-place.
sed -i '/^::1/s/^/#/' "$HOSTS_FILE"

echo "Updated $HOSTS_FILE. A backup was created at ${HOSTS_FILE}.bak"

# --- Final Verification and Instructions ---
echo
echo "--- Process Complete ---"
echo "IPv6 has been disabled in the system configuration."
echo

echo "To verify the changes:"
echo "1. Check if the IPv6 kernel parameters are set to 1:"
echo "   sysctl net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6"
echo "   (The output should show '= 1' for both)"
echo
echo "2. Check your network interfaces. There should be no 'inet6' addresses:"
echo "   ip a"
echo

echo "A system reboot is highly recommended to ensure all services and applications"
echo "start correctly with IPv6 fully disabled."
read -p "Do you want to reboot now? (y/N): " REBOOT_CHOICE

case "$REBOOT_CHOICE" in
  y|Y|yes|YES )
    echo "Rebooting now..."
    reboot
    ;;
  * )
    echo "Please reboot your system manually to complete the process."
    ;;
esac

exit 0
