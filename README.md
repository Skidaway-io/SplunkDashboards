# Splunk Tempo Dashboard Installer

This project automates the installation of Splunk Enterprise, imports a custom dashboard that displays output from the Snowflake app Tempo project, and sets up both admin and default user accounts. The script is designed to work on Amazon EC2 instances running Amazon Linux, as well as other Linux distributions.

## Prerequisites

- A Linux or Mac system 
- Root or sudo access
- Splunk Enterprise installer tarball (`.tgz` file) obtained separately

## What the Script Does

1. Updates the system packages
2. Locates the Splunk Enterprise installer in the current directory
3. Installs Splunk Enterprise
4. Configures Splunk to start automatically on boot
5. Sets up an admin user and a default user with restricted permissions
6. Configures the firewall (if applicable)
7. Imports the `anomaly_hub.xml` dashboard from the Tempo project
8. Restarts Splunk to apply all changes

## Usage

1. Obtain the Splunk Enterprise tarball from your authorized Splunk software provider.
2. Place the Splunk Enterprise tarball (e.g., `splunk-*-Linux-x86_64.tgz`) in the same directory as the script.
3. Open the script in a text editor and replace 'your_admin_password', 'default_user', and 'default_password' with your desired credentials.
4. Make the script executable:
   ```
   chmod +x splunk_tempo_install.sh
   ```
5. Run the script with sudo privileges:
   ```
   sudo ./splunk_tempo_install.sh
   ```

## Important Notes

- The script sets up two users: an admin user and a default user with restricted permissions.
- Ensure you set strong passwords for both the admin and default user in the script before running it.
- Firewall configuration may vary depending on your Linux distribution. The script uses `firewall-cmd`, which is common in Red Hat-based systems. You may need to adjust this for other distributions.
- Ensure you have sufficient disk space for Splunk Enterprise and its data.

## Post-Installation

After running the script, you can access the Splunk web interface at `http://your_server_ip:8000`. You can log in with either the admin credentials or the default user credentials you set up.

## Troubleshooting

- If the script fails to find the Splunk tarball, ensure it's in the same directory and follows the naming convention `splunk-*-Linux-x86_64.tgz`.
- If the dashboard doesn't appear, check the Splunk server logs at `/opt/splunk/var/log/splunk/splunkd.log`.
- Ensure that the `anomaly_hub.xml` file is correctly formatted and placed in the script's directory before running.
- If you encounter issues with user creation, check the Splunk server logs and ensure you're using the correct authentication credentials in the script.

## Security Considerations

- Always use strong, unique passwords for both the admin and default user accounts.
- Consider using HTTPS for the Splunk web interface in production environments.
- Review and adjust firewall rules as needed for your security requirements.
- Regularly review user access and permissions to ensure they align with the principle of least privilege.

## Support

For issues related to Splunk Enterprise, please refer to [Splunk's official documentation](https://docs.splunk.com/Documentation/Splunk).

For questions about the Snowflake app Tempo project integration, please contact your Snowflake support team or refer to the Tempo project documentation.
