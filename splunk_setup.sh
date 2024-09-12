#!/bin/bash

set -e

# Function to find the most recent Splunk tarball
find_splunk_tarball() {
    find . -maxdepth 1 -name "splunk-*-*-darwin-*.tgz" | sort -r | head -n 1
}

# Find the Splunk tarball
SPLUNK_PACKAGE=$(find_splunk_tarball)

if [ -z "$SPLUNK_PACKAGE" ]; then
    echo "No Splunk tarball found in the current directory."
    echo "Please download Splunk Enterprise from:"
    echo "https://www.splunk.com/en_us/download/splunk-enterprise.html"
    echo ""
    echo "For macOS, choose:"
    echo "- Intel Macs: 'Mac OS X'"
    echo "- M1/M2 Macs: 'Mac OS X ARM'"
    echo ""
    echo "Download the .tgz file and place it in this directory, then run this script again."
    exit 1
fi

echo "Found Splunk package: $SPLUNK_PACKAGE"

# Clean up any existing Splunk installation
echo "Cleaning up any existing Splunk installation..."
sudo rm -rf /opt/splunk

# Extract Splunk
echo "Extracting Splunk..."
sudo tar xzf "${SPLUNK_PACKAGE}" -C /opt

# Set correct permissions
echo "Setting correct permissions..."
sudo chown -R root:wheel /opt/splunk

# Start Splunk and accept license
echo "Starting Splunk and accepting license..."
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt

# Enable Splunk to start at boot
echo "Enabling Splunk to start at boot..."
sudo /opt/splunk/bin/splunk enable boot-start -user splunk

# Create admin user
echo "Setting admin password..."
read -sp "Enter a strong password for the Splunk admin user: " ADMIN_PASSWORD
echo ""
sudo /opt/splunk/bin/splunk edit user admin -password "${ADMIN_PASSWORD}" -role admin -auth admin:changeme

# Restart Splunk to apply changes
echo "Restarting Splunk to apply changes..."
sudo /opt/splunk/bin/splunk restart

echo "Splunk installation complete. Access the web interface at http://localhost:8000"
echo "You can log in with username 'admin' and the password you just set."
