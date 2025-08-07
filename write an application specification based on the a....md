# **Application Specification: Appx/MSIX Management Utility**

Version: 1.0  
Date: 2025-08-06

## **1\. Overview**

This document outlines the functional and technical specifications for a PowerShell-based graphical user interface (GUI) application. The utility will allow system administrators and users to view, search, and manage installed Appx and MSIX applications on a Windows system.

## **2\. Requirements**

### **2.1. Core Functionality**

* The application must list all installed Appx and MSIX applications for all users on the system.  
* The application must display the Name and Version of each package.  
* Users must be able to search/filter the list of applications by the package Name.

### **2.2. User Actions**

When a single application is selected from the list, the user must be able to perform the following actions:

* **Uninstall:** Remove the selected application from the system for the current user.  
* **Publish Per-Machine:** Re-register the application for all users on the machine. This makes a per-user installed application available to all users.

## **3\. Design and User Interface (UI)**

The application will be a single-window GUI.

### **3.1. Main Window Components**

* **Title:** "Appx/MSIX Management Utility"  
* **Search Field:** A text box labeled "Search by Name:" that allows users to type a package name. The application list should filter dynamically as the user types.  
* **Application List:** A data grid or list view with the following columns:  
  * **Name:** The Name property of the Appx/MSIX package.  
  * **Version:** The Version property of the Appx/MSIX package.  
* **Action Buttons:**  
  * **Uninstall:** A button that becomes active only when an application is selected.  
  * **Publish Per-Machine:** A button that becomes active only when an application is selected.  
* **Status Bar:** A read-only text area at the bottom of the window to display feedback, such as "Loading applications...", "Uninstalling \[PackageName\]...", "Operation successful," or error messages.

## **4\. Technical Specifications**

### **4.1. Platform**

* **Language:** PowerShell  
* **Version:** Compatible with PowerShell 5.1 and PowerShell 7.x.  
* **Framework:** The GUI can be implemented using Windows Presentation Foundation (WPF) or Windows Forms, both accessible from PowerShell.

### **4.2. PowerShell Command Implementation**

* **Listing Applications:**  
  * The application will use the Get-AppxPackage \-AllUsers cmdlet to retrieve the list of all installed packages.  
  * The properties Name, Version, and PackageFullName will be retrieved for each package.  
* **Searching:**  
  * The search functionality will filter the results of the Get-AppxPackage command based on the text entered in the search field. This will likely use a Where-Object filter on the Name property.  
  * Example: Get-AppxPackage \-AllUsers | Where-Object { $\_.Name \-like "\*$searchText\*" }  
* **Uninstalling an Application:**  
  * The application will use the Remove-AppxPackage cmdlet.  
  * The PackageFullName of the selected application will be used to identify the package for removal.  
  * Example: Remove-AppxPackage \-Package $selectedPackage.PackageFullName  
* **Publishing Per-Machine:**  
  * The application will execute the following command template, substituting the $PackageFullName variable with the PackageFullName property of the selected application.  
  * Command: Add-AppxPackage \-DisableDevelopmentMode \-Register (Get-AppxPackage \-AllUsers \-Name $selectedPackage.Name).InstallLocation \+ "\\AppxManifest.xml"

### **4.3. Error Handling**

* The application must gracefully handle errors that may occur during PowerShell command execution (e.g., insufficient permissions, package not found).  
* Error messages should be user-friendly and displayed in the status bar. Detailed error records should be logged to the console for debugging purposes.

## **5\. Use Case Workflow**

1. **Launch:** User starts the PowerShell script.  
2. **Initialization:** The GUI window appears. The application immediately runs Get-AppxPackage \-AllUsers and populates the data grid. A "Loading..." message is shown in the status bar.  
3. **Search:** The user types "Camera" into the search box. The list automatically filters to show only packages with "Camera" in their name.  
4. **Selection:** The user clicks on the "Windows Camera" application in the list. The "Uninstall" and "Publish Per-Machine" buttons become enabled.  
5. **Action:** The user clicks the "Uninstall" button.  
6. **Execution:** The application runs Remove-AppxPackage on the selected package. A message like "Uninstalling Windows Camera..." appears in the status bar.  
7. **Feedback:** Upon completion, the status bar updates to "Uninstallation successful." and the application list is refreshed, removing the uninstalled application. If an error occurs, the status bar shows "Error: Access denied." or a similar message.