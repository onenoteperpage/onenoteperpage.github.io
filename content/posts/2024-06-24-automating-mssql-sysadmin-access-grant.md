---
title: "Automating MSSQL SysAdmin Access Grant"
date: 2024-06-24T11:50:00+10:00
# weight: 1
# aliases: ["/first"]
tags: ["mssql"]
author: "Me"
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Automating MSSQL Sysadmin Access Grant for Specific Logins"
disableHLJS: true # to disable highlightjs
disableShare: true
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "/images/logos/microsoft-sql-server-logo-png-transparent.png" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---

When managing multiple MSSQL instances on a single server, ensuring consistent access control across all instances can be challenging. This PowerShell script automates the process of granting sysadmin access to a specific login (`[domain\userAcc1]`) for all MSSQL services on the local machine. The script first retrieves the names of all MSSQL services and then iterates over each service to set it to run under the LocalSystem account. It then stops the service, starts it in single-user mode, and executes a SQL command to create the login and assign it to the sysadmin role. Finally, the script restarts the service in normal mode, ensuring that the specified login has the necessary administrative privileges across all MSSQL instances. This automation simplifies the task of managing access controls, making it more efficient and less error-prone.

```powershell
# Script to grant sysadmin access to a specific login for all MSSQL services on the local machine

# Define the login to be granted access
$login_to_be_granted_access = "[domain\userAcc1]"

# Retrieve the names of all MSSQL services on the local machine
$service_names = (Get-Service *mssql*).Name

# Iterate over each MSSQL service to apply changes
foreach ($service_name in $service_names) {
    # Set the MSSQL service to run under the LocalSystem account
    SC.EXE config $service_name obj= LocalSystem
    
    # Construct the SQL Server instance name based on the service name
    $sql_server_instance = "{0}\{1}" -f (hostname), ($service_name -split '\$')[1]
    
    # Force stop the MSSQL service
    Stop-Service $service_name -Force -Confirm:$false
    
    # Start the MSSQL service in single-user mode with SQLCMD access
    net start $service_name /f /mSQLCMD
    
    # Execute SQL command to create login and add to sysadmin role
    sqlcmd.exe -E -S $sql_server_instance -Q "CREATE LOGIN $login_to_be_granted_access FROM WINDOWS; ALTER SERVER ROLE sysadmin ADD MEMBER $login_to_be_granted_access;"
    
    # Stop the MSSQL service
    net stop $service_name
    
    # Start the MSSQL service normally
    net start $service_name
}
```