#!/bin/bash

# Splunk Tempo Dashboard Installer
# This script installs Splunk Enterprise, imports the Tempo project dashboard, and sets up users

# Update the system
if command -v yum &> /dev/null; then
    sudo yum update -y
elif command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get upgrade -y
else
    echo "Unsupported package manager. Please update your system manually."
fi

# Find Splunk tarball in current directory
SPLUNK_TARBALL=$(ls splunk-*.tgz 2>/dev/null | head -n 1)

if [ -z "$SPLUNK_TARBALL" ]; then
    echo "Splunk installer not found in current directory. Please ensure the Splunk tarball (splunk-*-Linux-x86_64.tgz) is in this directory."
    exit 1
fi

echo "Found Splunk installer: $SPLUNK_TARBALL"

# Extract Splunk
sudo tar xvzf "$SPLUNK_TARBALL" -C /opt

# Start Splunk and accept license
sudo /opt/splunk/bin/splunk start --accept-license

# Enable Splunk to start at boot
sudo /opt/splunk/bin/splunk enable boot-start

# Create admin user (replace 'your_admin_password' with a strong password)
sudo /opt/splunk/bin/splunk edit user admin -password 'your_admin_password' -role admin -auth admin:changeme

# Create a default user (replace 'default_user' and 'default_password' with your chosen credentials)
sudo /opt/splunk/bin/splunk add user default_user -password 'default_password' -role user -auth admin:your_admin_password

# Configure firewall (if using firewalld)
if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=8000/tcp
    sudo firewall-cmd --reload
else
    echo "firewall-cmd not found. Please configure your firewall manually to allow port 8000."
fi

# Import dashboard from Tempo project
DASHBOARD_FILE="anomaly_hub.xml"
APP_CONTEXT="search"

if [ -f "$DASHBOARD_FILE" ]; then
    sudo cp "$DASHBOARD_FILE" "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/"
    sudo chown splunk:splunk "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/$DASHBOARD_FILE"
    echo "Tempo project dashboard imported successfully."
else
    echo "Dashboard file not found. Please ensure '$DASHBOARD_FILE' from the Tempo project is in the same directory as this script."
fi

# Restart Splunk to apply changes
sudo /opt/splunk/bin/splunk restart

echo "Splunk installation and Tempo dashboard import complete. Access the web interface at http://your_server_ip:8000"
echo "Please ensure you change both the admin and default user passwords if you haven't set strong passwords in the script."
