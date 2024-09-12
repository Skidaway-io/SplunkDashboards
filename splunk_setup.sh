#!/bin/bash

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

# Extract Splunk
echo "Extracting Splunk..."
sudo tar xvzf ${SPLUNK_PACKAGE} -C /opt

# The rest of the script remains the same...

# Start Splunk and accept license
sudo /opt/splunk/bin/splunk start --accept-license

# Enable Splunk to start at boot
sudo /opt/splunk/bin/splunk enable boot-start

# Create admin user (replace 'your_password' with a strong password)
sudo /opt/splunk/bin/splunk edit user admin -password 'test' -role admin -auth admin:changeme

# Restart Splunk to apply changes
sudo /opt/splunk/bin/splunk restart

echo "Splunk installation complete. Access the web interface at http://localhost:8000"
