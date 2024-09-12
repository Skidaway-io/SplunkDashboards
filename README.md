# Splunk Tempo Dashboard Installer

This project automates the installation of Splunk Enterprise and the import of a custom dashboard that displays output from the Snowflake app Tempo project. The script is designed to work on Amazon EC2 instances running Amazon Linux, as well as other Linux distributions.

## Prerequisites

- A Linux system (EC2 instance with Amazon Linux or any other Linux distribution)
- Root or sudo access
- Splunk Enterprise installer tarball (`.tgz` file) obtained separately
- The `anomaly_hub.xml` dashboard file from the Snowflake app Tempo project

## What the Script Does

1. Updates the system packages
2. Locates the Splunk Enterprise installer in the current directory
3. Installs Splunk Enterprise
4. Configures Splunk to start automatically on boot
5. Sets up an admin user for Splunk
6. Configures the firewall (if applicable)
7. Imports the `anomaly_hub.xml` dashboard from the Tempo project
8. Restarts Splunk to apply all changes

## Usage

1. Obtain the Splunk Enterprise tarball from your authorized Splunk software provider.
2. Place the Splunk Enterprise tarball (e.g., `splunk-*-Linux-x86_64.tgz`) in the same directory as the script.
3. Ensure you have the `anomaly_hub.xml` file in the same directory as the script.
4. Make the script executable:
   ```
   chmod +x splunk_tempo_install.sh
   ```
5. Run the script with sudo privileges:
   ```
   sudo ./splunk_tempo_install.sh
   ```

## Important Notes

- The script sets the Splunk admin password to 'test'. This should be changed immediately in a production environment.
- Firewall configuration may vary depending on your Linux distribution. The script uses `firewall-cmd`, which is common in Red Hat-based systems. You may need to adjust this for other distributions.
- Ensure you have sufficient disk space for Splunk Enterprise and its data.

## Post-Installation

After running the script, you can access the Splunk web interface at `http://your_server_ip:8000`. Log in with the admin credentials you set up, and you should see the imported Tempo project dashboard under the "search" app.

## Troubleshooting

- If the script fails to find the Splunk tarball, ensure it's in the same directory and follows the naming convention `splunk-*-Linux-x86_64.tgz`.
- If the dashboard doesn't appear, check the Splunk server logs at `/opt/splunk/var/log/splunk/splunkd.log`.
- Ensure that the `anomaly_hub.xml` file is correctly formatted and placed in the script's directory before running.

## Security Considerations

- Change the default admin password immediately after installation.
- Consider using HTTPS for the Splunk web interface in production environments.
- Review and adjust firewall rules as needed for your security requirements.

## Support

For issues related to Splunk Enterprise, please refer to [Splunk's official documentation](https://docs.splunk.com/Documentation/Splunk).

For questions about the Snowflake app Tempo project integration, please contact your Snowflake support team or refer to the Tempo project documentation.
