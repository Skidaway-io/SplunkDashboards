i#!/bin/bash

# Update the system
sudo yum update -y

# Download Splunk Enterprise
wget -O splunk-8.2.2-87344edfcdb4-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/8.2.2/linux/splunk-8.2.2-87344edfcdb4-Linux-x86_64.tgz"

# Extract Splunk
sudo tar xvzf splunk-8.2.2-87344edfcdb4-Linux-x86_64.tgz -C /opt

# Start Splunk and accept license
sudo /opt/splunk/bin/splunk start --accept-license

# Enable Splunk to start at boot
sudo /opt/splunk/bin/splunk enable boot-start

# Create admin user (replace 'your_password' with a strong password)
sudo /opt/splunk/bin/splunk edit user admin -password 'test' -role admin -auth admin:changeme

# Configure firewall (if using)
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# Import dashboard
# Replace 'my_dashboard.xml' with your dashboard file name
# Replace 'search' with your desired app context if different
DASHBOARD_FILE="my_dashboard.xml"
APP_CONTEXT="search"

if [ -f "$DASHBOARD_FILE" ]; then
    sudo cp "$DASHBOARD_FILE" "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/"
    sudo chown splunk:splunk "/opt/splunk/etc/apps/$APP_CONTEXT/local/data/ui/views/$DASHBOARD_FILE"
    echo "Dashboard imported successfully."
else
    echo "Dashboard file not found. Please ensure '$DASHBOARD_FILE' is in the same directory as this script."
fi

# Restart Splunk to apply changes
sudo /opt/splunk/bin/splunk restart

echo "Splunk installation and dashboard import complete. Access the web interface at http://your_ec2_ip:8000"
