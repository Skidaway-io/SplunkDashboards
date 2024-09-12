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

# Function to update the system
update_system() {
    case $1 in
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew update
            ;;
        ubuntu|debian)
            sudo apt-get update -y
            ;;
        centos|rhel|fedora)
            sudo yum update -y
            ;;
        *)
            echo "Unsupported operating system for automatic updates."
            ;;
    esac
}

# Function to install wget if not present
install_wget() {
    if ! command -v wget &> /dev/null; then
        case $1 in
            macos)
                brew install wget
                ;;
            ubuntu|debian)
                sudo apt-get install wget -y
                ;;
            centos|rhel|fedora)
                sudo yum install wget -y
                ;;
            *)
                echo "Please install wget manually and run the script again."
                exit 1
                ;;
        esac
    fi
}

# Detect the operating system
OS=$(detect_os)
echo "Detected OS: $OS"

# Update the system
update_system $OS

# Install wget if not present
install_wget $OS

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
case $OS in
    macos)
        echo "On macOS, please configure the firewall manually if needed."
        ;;
    ubuntu|debian)
        sudo ufw allow 8000/tcp
        sudo ufw reload
        ;;
    centos|rhel|fedora)
        sudo firewall-cmd --permanent --add-port=8000/tcp
        sudo firewall-cmd --reload
        ;;
    *)
        echo "Please configure the firewall manually to allow port 8000/tcp."
        ;;
esac

# Import dashboard
# Replace 'my_dashboard.xml' with your dashboard file name
# Replace 'search' with your desired app context if different
DASHBOARD_FILE="anomaly_hub.xml"
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

echo "Splunk installation and dashboard import complete. Access the web interface at http://localhost:8000"