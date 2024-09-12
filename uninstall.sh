#!/bin/bash
# Splunk Tempo Dashboard Uninstaller
# This script removes Splunk Enterprise, stops all related processes, and cleans up the system

set -e  # Exit immediately if a command exits with a non-zero status.

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or using sudo"
        exit 1
    fi
}

# Function to stop Splunk and remove from boot
stop_splunk() {
    if [ -f "/opt/splunk/bin/splunk" ]; then
        echo "Stopping Splunk..."
        /opt/splunk/bin/splunk stop
        echo "Removing Splunk from boot-start..."
        /opt/splunk/bin/splunk disable boot-start
    else
        echo "Splunk binary not found. It may have already been removed."
    fi
}

# Function to remove Splunk files
remove_splunk_files() {
    echo "Removing Splunk files..."
    rm -rf /opt/splunk
    rm -rf /etc/init.d/splunk
    rm -rf /etc/systemd/system/splunk.service
}

# Function to remove Splunk user and group
remove_splunk_user() {
    if id "splunk" &>/dev/null; then
        echo "Removing Splunk user and group..."
        userdel -r splunk 2>/dev/null || true
        groupdel splunk 2>/dev/null || true
    else
        echo "Splunk user not found. Skipping user removal."
    fi
}

# Function to remove firewall rules
remove_firewall_rules() {
    if command -v firewall-cmd &> /dev/null; then
        echo "Removing firewall rules (firewalld)..."
        firewall-cmd --permanent --remove-port=8000/tcp
        firewall-cmd --reload
    elif command -v ufw &> /dev/null; then
        echo "Removing firewall rules (ufw)..."
        ufw delete allow 8000/tcp
    else
        echo "No supported firewall detected. Please remove any manually added firewall rules for Splunk."
    fi
}

# Function to clean up any remaining processes
cleanup_processes() {
    echo "Cleaning up any remaining Splunk processes..."
    pkill -f splunkd || true
    pkill -f splunk || true
}

# Main execution
main() {
    check_root
    stop_splunk
    remove_splunk_files
    remove_splunk_user
    remove_firewall_rules
    cleanup_processes
    echo "Splunk has been completely removed from the system."
    echo "Note: This script does not remove any data or configurations you may have created outside of the /opt/splunk directory."
    echo "If you have any custom data or configurations elsewhere, please remove them manually."
}

main
