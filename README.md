# SecureBackupSync

SecureBackupSync is an interactive command-line interface (CLI) backup script that allows you to create backups of local directories, encrypt them, and send them to various storage destinations such as Minio, Google Drive, AWS S3, or a remote server via SCP.

## Features

- **Interactive Backup**: The `backup.sh` script prompts the user for the directory to back up and the destination to send it to.
- **Compression and Encryption**: The selected directory is compressed into a `.tar.gz` file and then encrypted using GPG (asymmetric or symmetric encryption) or OpenSSL (symmetric AES-256 encryption).
- **Multiple Destinations**: Supports sending the backup to:
  - **Minio** (S3-compatible storage)
  - **Google Drive**
  - **AWS S3**
  - **Remote server via SCP**
- **Detailed Logs**: All operations are logged in files within the `logs/` directory.
- **Notifications**: Optionally sends notifications via DISCORD or email upon completion (or failure) of the backup.

## Prerequisites

Before using SecureBackupSync, ensure you have installed/configured:
- **Bash**: The script uses Bash and standard Unix utilities (`tar`, etc.).
- **GPG** (optional): Required for GPG encryption. Set up a GPG key or prepare a password for symmetric encryption.
- **OpenSSL** (optional): Required for encryption via OpenSSL.
- **AWS CLI Client** (optional): Required for sending to AWS S3 or Minio. Configure credentials in the configuration file or your environment. Install the [`AWS CLI`](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **Google Drive CLI Tool** (optional): For example, the [`gdrive`](https://github.com/glotlabs/gdrive) tool to send files to Google Drive. Ensure it is authenticated before use.
  ```
    wget https://github.com/glotlabs/gdrive/releases/download/3.9.1/gdrive_linux-x64.tar.gz
    tar -xzf gdrive_linux-x64.tar.gz
    sudo mv gdrive /usr/local/bin/
    sudo chmod u+x /usr/local/bin/gdrive
    gdrive version
  ```
- **SSH Access** (optional): To send via SCP, you need SSH access to the destination server (configure user, host, port, and key or password).
- **Email Utility** (optional): For email notifications, configure the `mail` command or similar on the system, or adjust the script to use your preferred email sending method. Install `mailutils` for this function.
- **cURL**: Required for sending notifications via DISCORD webhook.

## Configuration

1. Make a copy of the `config.example.sh` file and rename it to `config.sh`.
2. Edit the `config.sh` file with the appropriate information:
   - Set credentials and configurations for the destinations you plan to use (Minio, Google Drive, AWS S3, SCP).
   - Provide the encryption password (`ENCRYPTION_PASSWORD`) and/or the GPG recipient (`GPG_RECIPIENT`) for encryption.
   - Configure the DISCORD webhook URL (`DISCORD_WEBHOOK_URL`) and/or the destination email (`EMAIL_TO`) for notifications, if desired.
3. Ensure the main script is executable: `chmod +x backup.sh`.

## Usage

To start the backup, run the main script in the terminal:
