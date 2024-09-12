#!/bin/bash
# Splunk Tempo Dashboard Installer
# This script installs Splunk Enterprise, imports the Tempo project dashboard, and sets up users
set -e  # Exit immediately if a command exits with a non-zero status.

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or using sudo"
        exit 1
    fi
}

# Function to update the system
update_system() {
    if command -v yum &> /dev/null; then
        yum update -y
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get upgrade -y
    elif command -v zypper &> /dev/null; then
        zypper refresh && zypper update -y
    else
        echo "Unsupported package manager. Please update your system manually."
        exit 1
    fi
}

# Function to install required dependencies
install_dependencies() {
    if command -v tar &> /dev/null; then
        echo "tar is already installed. Skipping installation."
    else
        echo "tar is not installed. Attempting to install..."
        if command -v yum &> /dev/null; then
            yum install -y tar
        elif command -v apt-get &> /dev/null; then
            apt-get install -y tar
        elif command -v zypper &> /dev/null; then
            zypper install -y tar
        else
            echo "Unsupported package manager. Please install tar manually."
            exit 1
        fi
    fi
}

# Function to check for Splunk tarball
check_splunk_tarball() {
    SPLUNK_TARBALL=$(ls splunk-*.tgz 2>/dev/null | head -n 1)
    if [ -z "$SPLUNK_TARBALL" ]; then
        echo "Splunk installer not found in current directory. Please ensure the Splunk tarball (splunk-*-Linux-x86_64.tgz) is in this directory."
        exit 1
    fi
    echo "Found Splunk installer: $SPLUNK_TARBALL"
}

# Function to install Splunk
install_splunk() {
    tar xvzf "$SPLUNK_TARBALL" -C /opt
    /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt
    /opt/splunk/bin/splunk enable boot-start
}

# Function to create users
create_users() {
    /opt/splunk/bin/splunk edit user admin -password 'your_admin_password' -role admin -auth admin:changeme
    /opt/splunk/bin/splunk add user default_user -password 'default_password' -role user -auth admin:your_admin_password
}

# Function to configure firewall
configure_firewall() {
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=8000/tcp
        firewall-cmd --reload
    elif command -v ufw &> /dev/null; then
        ufw allow 8000/tcp
    else
        echo "No supported firewall detected. Please configure your firewall manually to allow port 8000."
    fi
}

# Function to import dashboard
import_dashboard() {
    DASHBOARD_FILE="anomaly_hub.xml"
    APP_CONTEXT="search"
    if [ -f "$DASHBOARD_FILE" ]; then
        cp "$DASHBOARD_FILE" "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/"
        chown splunk:splunk "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/$DASHBOARD_FILE"
        echo "Tempo project dashboard imported successfully."
    else
        echo "Dashboard file not found. Please ensure '$DASHBOARD_FILE' from the Tempo project is in the same directory as this script."
    fi
}

# Main execution
main() {
    check_root
    #update_system
    install_dependencies
    check_splunk_tarball
    install_splunk
    create_users
    configure_firewall
    import_dashboard
    /opt/splunk/bin/splunk restart
    echo "Splunk installation and Tempo dashboard import complete. Access the web interface at http://your_server_ip:8000"
    echo "Please ensure you change both the admin and default user passwords if you haven't set strong passwords in the script."
}

main
