## [1.0.0] - 2025-03-02

### Added
- **Interactive Backup:**  
  - Implementation of the main script `backup.sh`, allowing the user to select the backup directory via CLI.
  - Creation of a `.tar.gz` file from the specified directory.

- **Encryption:**  
  - Support for backup encryption using:
    - **GPG:** Support for asymmetric encryption (with `GPG_RECIPIENT`) or symmetric encryption (with `ENCRYPTION_PASSWORD`).
    - **OpenSSL:** Use of the AES-256-CBC algorithm with the `-pbkdf2` option for enhanced security.
  - Modularization of encryption in `libs/encrypt.sh`.

- **Upload to Multiple Destinations:**  
  - Implementation of the upload module in `libs/upload.sh` with support for:
    - **Minio:** Upload via AWS CLI configured for a custom endpoint.
    - **Google Drive:** Use of the updated command `gdrive files upload`, with support for specifying the destination folder (via `GDRIVE_FOLDER_ID`).
    - **AWS S3:** Upload to a configured bucket.
    - **SCP:** File transfer via SSH, with support for SSH key or password authentication.
  
- **Logs and Notifications:**  
  - Detailed execution logs stored in the `logs/` directory.
  - Integrated notifications:
    - Via **Discord** (using webhook).
    - Via **email** (using the `mail` command).

- **Configuration and Environment:**  
  - Configuration files (`config.example.sh` and `config.sh`) to facilitate environment customization.
  - Updated `.gitignore` file to ignore sensitive files, logs, and keys.

### Improved
- **Error Handling and Debugging:**  
  - Detailed and organized error messages in each module, displaying the complete output of executed commands (using `sed` for indentation).
  - Use of `PIPESTATUS` to correctly capture the exit codes of pipelines, ensuring that encryption and upload failures are detected and handled.
  - Update of the Google Drive upload function to the modern command `gdrive files upload`.

- **Code Modularization and Organization:**  
  - Separation of code into libraries (`libs/encrypt.sh` and `libs/upload.sh`) to facilitate maintenance and future extensions.

### Fixed
- **Execution Flow:**  
  - Correction in the flow to stop execution if encryption or upload fails, ensuring proper feedback to the user.
  - Adjustments to prevent debug commands (like `tee`) from masking real errors, using the `PIPESTATUS` variable.

### Future Work
- Inclusion of more destination options and integrations with other storage services.
- Improvements to the interactive interface to make it easier for less technical users.
- Additional documentation and debug examples to support specific error handling.