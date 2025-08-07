# AppxMSIX Management Utility
# Version 1.1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to write log messages
function Write-Log {
    param([string]$Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path "$PSScriptRoot\AppxMSIX_Utility.log" -Value $logMessage
    Write-Host $logMessage
}

Write-Log "Script started"

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Appx/MSIX Management Utility"
$form.Size = New-Object System.Drawing.Size(800,650)
$form.StartPosition = "CenterScreen"

# Create admin note label
$adminNoteLabel = New-Object System.Windows.Forms.Label
$adminNoteLabel.Location = New-Object System.Drawing.Point(10,560)
$adminNoteLabel.Size = New-Object System.Drawing.Size(760,30)
$adminNoteLabel.Text = "Note: Run as administrator for full functionality (viewing all users' packages and publishing per-machine)."
$form.Controls.Add($adminNoteLabel)

# Create the search field
$searchLabel = New-Object System.Windows.Forms.Label
$searchLabel.Location = New-Object System.Drawing.Point(10,20)
$searchLabel.Size = New-Object System.Drawing.Size(100,20)
$searchLabel.Text = "Search by Name:"
$form.Controls.Add($searchLabel)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(120,20)
$searchBox.Size = New-Object System.Drawing.Size(200,20)
$form.Controls.Add($searchBox)

# Create the application list view
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(10,50)
$listView.Size = New-Object System.Drawing.Size(760,400)
$listView.View = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.Columns.Add("Name", 300)
$listView.Columns.Add("Version", 100)
$listView.Columns.Add("Installation Type", 200)
$form.Controls.Add($listView)

# Create the action buttons
$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Location = New-Object System.Drawing.Point(10,460)
$uninstallButton.Size = New-Object System.Drawing.Size(100,30)
$uninstallButton.Text = "Uninstall"
$uninstallButton.Enabled = $false
$form.Controls.Add($uninstallButton)

$publishButton = New-Object System.Windows.Forms.Button
$publishButton.Location = New-Object System.Drawing.Point(120,460)
$publishButton.Size = New-Object System.Drawing.Size(150,30)
$publishButton.Text = "Publish Per-Machine"
$publishButton.Enabled = $false
$form.Controls.Add($publishButton)

# Create the status bar
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = "Ready (Displaying packages for current user only)"
$form.Controls.Add($statusBar)

# Create an error label
$errorLabel = New-Object System.Windows.Forms.Label
$errorLabel.Location = New-Object System.Drawing.Point(10,500)
$errorLabel.Size = New-Object System.Drawing.Size(760,30)
$errorLabel.ForeColor = [System.Drawing.Color]::Red
$form.Controls.Add($errorLabel)

# Function to check if script is running with admin privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Function to load applications
function Load-Applications {
    $listView.Items.Clear()
    $statusBar.Text = "Loading applications..."
    $errorLabel.Text = ""
    $isAdmin = Test-Admin
    try {
        if ($isAdmin) {
            Write-Log "Attempting to get all user packages"
            $allUserApps = Get-AppxPackage -AllUsers
            Write-Log "Successfully retrieved all user packages"
        } else {
            Write-Log "Not running as admin. Only retrieving current user packages."
        }
        
        Write-Log "Attempting to get current user packages"
        $currentUserApps = Get-AppxPackage
        Write-Log "Successfully retrieved current user packages"
        
        foreach ($app in $currentUserApps) {
            $item = New-Object System.Windows.Forms.ListViewItem($app.Name)
            $item.SubItems.Add($app.Version)
            if ($isAdmin -and $allUserApps.PackageFullName -contains $app.PackageFullName) {
                $item.SubItems.Add("Per-Machine")
            } else {
                $item.SubItems.Add("Per-User")
            }
            $item.Tag = $app.PackageFullName
            [void]$listView.Items.Add($item)
        }
        if ($isAdmin) {
            $statusBar.Text = "Ready (Displaying $($listView.Items.Count) packages for all users)"
        } else {
            $statusBar.Text = "Ready (Displaying $($listView.Items.Count) packages for current user only)"
        }
        Write-Log "Successfully loaded $($listView.Items.Count) packages"
    }
    catch {
        $errorMessage = "Error: $($_.Exception.Message)"
        $errorLabel.Text = $errorMessage
        $statusBar.Text = "Failed to load applications"
        Write-Log $errorMessage
    }
}

# Function to filter applications
function Filter-Applications {
    $searchText = $searchBox.Text
    $listView.Items.Clear()
    $errorLabel.Text = ""
    $isAdmin = Test-Admin
    try {
        if ($isAdmin) {
            $allUserApps = Get-AppxPackage -AllUsers
        }
        $currentUserApps = Get-AppxPackage | Where-Object { $_.Name -like "*$searchText*" }
        foreach ($app in $currentUserApps) {
            $item = New-Object System.Windows.Forms.ListViewItem($app.Name)
            $item.SubItems.Add($app.Version)
            if ($isAdmin -and $allUserApps.PackageFullName -contains $app.PackageFullName) {
                $item.SubItems.Add("Per-Machine")
            } else {
                $item.SubItems.Add("Per-User")
            }
            $item.Tag = $app.PackageFullName
            [void]$listView.Items.Add($item)
        }
    }
    catch {
        $errorMessage = "Error: $($_.Exception.Message)"
        $errorLabel.Text = $errorMessage
        Write-Log $errorMessage
    }
}

# Event handler for search box
$searchBox.Add_TextChanged({
    Filter-Applications
})

# Event handler for list view selection
$listView.Add_SelectedIndexChanged({
    if ($listView.SelectedItems.Count -gt 0) {
        $uninstallButton.Enabled = $true
        $publishButton.Enabled = $true
    } else {
        $uninstallButton.Enabled = $false
        $publishButton.Enabled = $false
    }
})

# Event handler for uninstall button
$uninstallButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $packageFullName = $listView.SelectedItems[0].Tag
        $packageName = $listView.SelectedItems[0].SubItems[0].Text
        Write-Log "Attempting to uninstall package: $packageName"
        $statusBar.Text = "Uninstalling $packageName..."
        $errorLabel.Text = ""
        try {
            Remove-AppxPackage -Package $packageFullName
            $statusBar.Text = "Uninstallation successful."
            Write-Log "Successfully uninstalled package: $packageName"
            Load-Applications
        } catch {
            $errorMessage = "Error: $($_.Exception.Message)"
            $errorLabel.Text = $errorMessage
            $statusBar.Text = "Uninstallation failed."
            Write-Log "Failed to uninstall package: $packageName. $errorMessage"
        }
    }
})

# Event handler for publish per-machine button
$publishButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $packageName = $listView.SelectedItems[0].SubItems[0].Text
        Write-Log "Attempting to publish package per-machine: $packageName"
        $statusBar.Text = "Publishing $packageName per-machine..."
        $errorLabel.Text = ""
        try {
            if (-not (Test-Admin)) {
                throw "Administrator privileges required to publish per-machine."
            }
            $app = Get-AppxPackage -Name $packageName
            Add-AppxPackage -DisableDevelopmentMode -Register "$($app.InstallLocation)\AppxManifest.xml"
            $statusBar.Text = "Publish per-machine successful."
            Write-Log "Successfully published package per-machine: $packageName"
            Load-Applications
        } catch {
            $errorMessage = "Error: $($_.Exception.Message)"
            $errorLabel.Text = $errorMessage
            $statusBar.Text = "Publish per-machine failed."
            Write-Log "Failed to publish package per-machine: $packageName. $errorMessage"
            [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

# Load applications on startup
Load-Applications

# Suppress verbose output
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Show the form
try {
    Write-Log "Attempting to show the form"
    $form.Add_Shown({
        $form.Activate()
        if (-not (Test-Admin)) {
            [System.Windows.Forms.MessageBox]::Show("This application is running without administrator privileges. Some features may be limited, and all packages will be shown as per-user.", "Limited Functionality", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })
    $form.ShowDialog()
}
catch {
    $errorMessage = "Error showing form: $($_.Exception.Message)"
    Write-Log $errorMessage
}

Write-Log "Script ended"
