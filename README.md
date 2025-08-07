# AppXManage - Appx/MSIX Management Utility

A PowerShell-based GUI application for managing Appx and MSIX applications on Windows systems.

## Features

- **View All Applications**: Lists all installed Appx and MSIX applications for all users
- **Search and Filter**: Real-time search functionality to filter applications by name
- **Uninstall Applications**: Remove selected applications from the current user
- **Publish Per-Machine**: Re-register applications to make them available to all users
- **User-Friendly Interface**: Clean WPF-based GUI with status feedback

## Requirements

- Windows 10/11
- PowerShell 5.1 or PowerShell 7.x
- Administrator privileges (recommended for full functionality)

## Usage

1. **Launch the Application**:
   ```powershell
   .\AppXManager.ps1
   ```

2. **Browse Applications**:
   - The application automatically loads all installed Appx/MSIX packages
   - Use the search box to filter applications by name
   - Click on an application to select it

3. **Manage Applications**:
   - **Uninstall**: Select an application and click "Uninstall" to remove it for the current user
   - **Publish Per-Machine**: Select an application and click "Publish Per-Machine" to make it available to all users

## Technical Details

The application uses the following PowerShell cmdlets:
- `Get-AppxPackage -AllUsers`: To retrieve all installed packages
- `Remove-AppxPackage`: To uninstall packages
- `Add-AppxPackage -Register`: To publish packages per-machine

## Security Note

Some operations may require administrator privileges. Run PowerShell as an administrator for full functionality.

## Troubleshooting

- **Access Denied Errors**: Run PowerShell as administrator
- **Package Not Found**: Ensure the package is still installed and try refreshing
- **Registration Errors**: Verify the package's manifest file exists and is accessible
Random idea for a niche problem with Appx
