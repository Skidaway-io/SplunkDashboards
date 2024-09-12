#!/bin/bash

# Function to detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Function to remove firewall rules
remove_firewall_rule() {
    case $1 in
        macos)
            echo "On macOS, please remove the firewall rule manually if you added one."
            ;;
        ubuntu|debian)
            sudo ufw delete allow 8000/tcp
            sudo ufw reload
            ;;
        centos|rhel|fedora)
            sudo firewall-cmd --permanent --remove-port=8000/tcp
            sudo firewall-cmd --reload
            ;;
        *)
            echo "Please remove the firewall rule manually if you added one."
            ;;
    esac
}

# Detect the operating system
OS=$(detect_os)
echo "Detected OS: $OS"

# Stop Splunk service
echo "Stopping Splunk service..."
sudo /opt/splunk/bin/splunk stop

# Disable Splunk from starting at boot
echo "Disabling Splunk from starting at boot..."
sudo /opt/splunk/bin/splunk disable boot-start

# Remove Splunk files
echo "Removing Splunk files..."
sudo rm -rf /opt/splunk

# Remove Splunk user and group
echo "Removing Splunk user and group..."
sudo userdel splunk
sudo groupdel splunk

# Remove firewall rule
echo "Removing firewall rule..."
remove_firewall_rule $OS

# Remove any remaining Splunk-related files
echo "Removing any remaining Splunk-related files..."
sudo rm -rf /etc/init.d/splunk
sudo rm -rf /etc/systemd/system/splunkd.service

# Clean up systemd
if [[ "$OS" != "macos" ]]; then
    echo "Reloading systemd..."
    sudo systemctl daemon-reload
fi

# Remove logs
echo "Removing Splunk logs..."
sudo rm -rf /var/log/splunk

# Remove any Splunk-related environment variables
echo "Removing Splunk-related environment variables..."
sudo sed -i '/SPLUNK/d' /etc/environment
sudo sed -i '/splunk/d' /etc/profile
sudo sed -i '/SPLUNK/d' /etc/profile

# Remind user to remove any manual configurations
echo "Please remember to remove any manual configurations you may have added, such as:"
echo "- Entries in /etc/hosts"
echo "- Cron jobs"
echo "- Custom scripts or aliases"

echo "Splunk has been uninstalled. You may need to restart your system for all changes to take effect."
