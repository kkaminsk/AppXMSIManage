# AppXManage - Appx/MSIX Management Utility

A PowerShell-based GUI application for managing Appx and MSIX applications on Windows systems.

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Security Considerations](#security-considerations)
7. [Future Enhancements](#future-enhancements)
8. [Contributing](#contributing)
9. [License](#license)

## Overview

AppXManage is a powerful utility designed for system administrators and users to efficiently manage Appx and MSIX applications on Windows systems. This tool provides a user-friendly graphical interface for viewing, searching, and managing installed applications, streamlining the process of application management on Windows platforms.

## Features

- List all installed Appx and MSIX applications for all users on the system
- Display Name and Version of each package
- Search and filter applications by package Name
- Uninstall selected applications for the current user or machine
- Publish applications per-machine, making them available to all users
- User-friendly GUI with intuitive controls
- Real-time search functionality
- Detailed status updates and error reporting

## Requirements

- Windows 10 or later
- PowerShell 5.1 or PowerShell 7.x
- Administrator privileges for full functionality

## Installation

1. Clone this repository or download the `AppxMSIX_Management_Utility.ps1` file.
2. Ensure that your PowerShell execution policy allows running scripts. You may need to run `Set-ExecutionPolicy RemoteSigned` in an elevated PowerShell prompt.

## Usage

1. Right-click on `AppxMSIX_Management_Utility.ps1` and select "Run with PowerShell" to launch the application with standard user privileges.
2. For full functionality, run PowerShell as an administrator, navigate to the script's directory, and execute:
   ```
   .\AppxMSIX_Management_Utility.ps1
   ```
3. Use the search box to filter applications by name.
4. Select an application from the list to enable the action buttons.
5. Click "Uninstall" to remove the selected application for the current user.
6. Click "Publish Per-Machine" to make a per-user installed application available to all users (requires admin privileges).

Note: Running without administrator privileges will limit some features, and all packages will be shown as per-user.

## Security Considerations

- The application runs with the least privileges necessary to perform its functions.
- All user inputs are sanitized to prevent injection attacks or unintended command execution.
- The application respects Windows security policies and does not bypass system-level restrictions.
- Logging does not include sensitive information such as full file paths or user-specific data.

## Future Enhancements

- Multi-select functionality for batch operations
- Export list of installed applications to CSV
- "Repair" function for corrupted Appx/MSIX packages

## Contributing

Contributions to AppXManage are welcome! Please feel free to submit pull requests, create issues or spread the word.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.