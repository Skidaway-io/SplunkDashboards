#!/bin/bash

set -e

# Function to detect the operating system and architecture
detect_os_and_arch() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        ARCH=$(uname -m)
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="$ID"
        ARCH=$(uname -m)
    else
        OS="unknown"
        ARCH="unknown"
    fi
    echo "$OS $ARCH"
}

# Detect the operating system and architecture
OS_AND_ARCH=$(detect_os_and_arch)
echo "Detected OS and Architecture: $OS_AND_ARCH"

# Set the correct Splunk package based on OS and architecture
case $OS_AND_ARCH in
    "macos x86_64")
        SPLUNK_PACKAGE="splunk-9.0.4.1-419ad9369127-darwin-64.tgz"
        ;;
    "macos arm64")
        SPLUNK_PACKAGE="splunk-9.0.4.1-419ad9369127-darwin-aarch64.tgz"
        ;;
    *)
        echo "Unsupported OS or architecture. Please download the appropriate Splunk package manually."
        exit 1
        ;;
esac

# Download Splunk Enterprise
echo "Downloading Splunk Enterprise..."
curl -L -O "https://download.splunk.com/products/splunk/releases/9.0.4.1/darwin/${SPLUNK_PACKAGE}"

# Verify the download
if [ ! -f "${SPLUNK_PACKAGE}" ]; then
    echo "Download failed. Please check your internet connection and try again."
    exit 1
fi

# Check file size (should be around 383 MB)
FILE_SIZE=$(du -m "${SPLUNK_PACKAGE}" | cut -f1)
if [ "${FILE_SIZE}" -lt 350 ]; then
    echo "The downloaded file seems too small. It might be corrupted. Please try running the script again."
    exit 1
fi

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

# Create admin user (replace 'your_password' with a strong password)
echo "Setting admin password..."
sudo /opt/splunk/bin/splunk edit user admin -password 'your_password' -role admin -auth admin:changeme

# Restart Splunk to apply changes
echo "Restarting Splunk to apply changes..."
sudo /opt/splunk/bin/splunk restart

echo "Splunk installation complete. Access the web interface at http://localhost:8000"
echo "Please remember to change 'your_password' in the script to a strong, unique password before running it."

# Clean up the downloaded package
rm "${SPLUNK_PACKAGE}"
