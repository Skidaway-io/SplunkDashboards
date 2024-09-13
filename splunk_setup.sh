#!/bin/bash
# Cross-platform Splunk Tempo Dashboard Installer
# This script installs Splunk Enterprise, imports the Tempo project dashboard, and sets up users on both macOS and Linux
set -e  # Exit immediately if a command exits with a non-zero status.

# Function to check if running as root/sudo
check_privileges() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run as root or using sudo"
        exit 1
    fi
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS detected"
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux detected"
        OS="linux"
    else
        echo "Unsupported operating system"
        exit 1
    fi
}

# Function to install required dependencies
install_dependencies() {
    if command -v tar &> /dev/null; then
        echo "tar is already installed. Skipping installation."
    else
        echo "tar is not installed. Attempting to install..."
        if [ "$OS" == "linux" ]; then
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y tar
            elif command -v yum &> /dev/null; then
                yum install -y tar
            elif command -v zypper &> /dev/null; then
                zypper install -y tar
            else
                echo "Unsupported package manager. Please install tar manually."
                exit 1
            fi
        elif [ "$OS" == "macos" ]; then
            if command -v brew &> /dev/null; then
                brew install gnu-tar
            else
                echo "Homebrew not found. Please install Homebrew and gnu-tar manually."
                exit 1
            fi
        fi
    fi
}

# Function to check for Splunk tarball
check_splunk_tarball() {
    SPLUNK_TARBALL=$(ls splunk-*.tgz 2>/dev/null | head -n 1)
    if [ -z "$SPLUNK_TARBALL" ]; then
        echo "Splunk installer not found in current directory. Please ensure the Splunk tarball (splunk-*.tgz) is in this directory."
        exit 1
    fi
    echo "Found Splunk installer: $SPLUNK_TARBALL"
}

# Function to check if Splunk is already installed
check_splunk_installed() {
    if [ -d "/opt/splunk" ] && [ -f "/opt/splunk/bin/splunk" ]; then
        echo "Splunk is already installed."
        return 0
    else
        echo "Splunk is not installed."
        return 1
    fi
}

# Function to install Splunk
install_splunk() {
    tar xvzf "$SPLUNK_TARBALL" -C /opt
    if [ "$OS" == "linux" ]; then
        /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
        /opt/splunk/bin/splunk enable boot-start
    elif [ "$OS" == "macos" ]; then
        /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
        echo "To enable Splunk to start at boot on macOS, follow Splunk's official documentation."
    fi
}

# Function to create users
create_users() {
    /opt/splunk/bin/splunk edit user admin -password 'password' -role admin -auth admin:changeme
    /opt/splunk/bin/splunk add user default_user -password 'default_password' -role user -auth admin:your_admin_password
    
    # Set the file path
    FILE_PATH="/opt/splunk/etc/system/local/user-seed.conf"
    # Create the file with the specified content
    cat << EOF > "$FILE_PATH"
[user_info]
USERNAME = admin
PASSWORD = password
EOF
    # Set the file ownership to root
    chown root:root "$FILE_PATH"
}

# Function to configure firewall
configure_firewall() {
    if [ "$OS" == "linux" ]; then
        if command -v firewall-cmd &> /dev/null; then
            firewall-cmd --permanent --add-port=8000/tcp
            firewall-cmd --reload
        elif command -v ufw &> /dev/null; then
            ufw allow 8000/tcp
        else
            echo "No supported firewall detected. Please configure your firewall manually to allow port 8000."
        fi
    elif [ "$OS" == "macos" ]; then
        echo "On macOS, you may need to configure the firewall manually. Ensure that port 8000 is open for Splunk Web access."
    fi
}

# Updated Function to import dashboard using Splunk CLI
import_dashboard() {
    DASHBOARD_FILE="anomaly_hub.xml"
    APP_NAME="search"
    ADMIN_USERNAME="admin"
    ADMIN_PASSWORD="password"

    if [ -f "$DASHBOARD_FILE" ]; then
        echo "Importing dashboard using Splunk CLI..."
        /opt/splunk/bin/splunk add dashboard "$DASHBOARD_FILE" -auth "$ADMIN_USERNAME:$ADMIN_PASSWORD" -app "$APP_NAME"
        if [ $? -eq 0 ]; then
            echo "Tempo project dashboard imported successfully."
        else
            echo "Failed to import dashboard. Please check Splunk logs for more information."
        fi
    else
        echo "Dashboard file not found. Please ensure '$DASHBOARD_FILE' from the Tempo project is in the same directory as this script."
    fi
}

# Main execution
main() {
    check_privileges
    detect_os
    install_dependencies

    if check_splunk_installed; then
        echo "Skipping Splunk installation and user setup. Proceeding to dashboard import."
    else
        check_splunk_tarball
        install_splunk
        create_users
        configure_firewall
    fi

    #import_dashboard
    /opt/splunk/bin/splunk restart
    echo "Splunk installation (if needed) complete. Access the web interface at http://localhost:8000"
    echo "Please ensure you change the admin user password if you haven't set strong passwords in the script."
}

main
