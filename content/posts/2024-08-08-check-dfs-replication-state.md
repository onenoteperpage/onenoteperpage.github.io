---
title: "Check DFS Replication State"
date: 2024-08-08T12:24:00+10:00
# weight: 1
# aliases: ["/first"]
tags: ["dfs","replication"]
author: "Me"
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Investigation and understand DFS replication state between servers"
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
    image: "/images/logos/dfs-namespace-and-folder-targets.jpg" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---

When managing a Distributed File System (DFS) in a Windows environment, it's essential to monitor the health and status of replication activities. Two useful commands in this regard are `dfsrdiag replicationstate` and `Get-WmiObject`. In this article, we'll explore what these commands do and how you can use them to check the state of DFS replication, with the flexibility of replacing server names with variables for more dynamic scripting.

## Understanding DSFR and Its Importance

DFS Replication (DFSR) is a role service in Windows Server that allows you to replicate folders (including those that are part of a DFS namespace) across multiple servers. It ensures that files are synchronized between servers, making it a vital component for redundancy, data availability, and load balancing.

## Command 1: Checking Replication State with dfsrdiag

The `dfsrdiag` command-line tool provides various diagnostics for DFSR. One of its subcommands, `replicationstate`, is particularly useful for checking the current state of replication activities on a specific server.

### Basic Usage

```powershell
dfsrdiag replicationstate /member:au-syd-app1
```

In this command:

- `/member:au-syd-app1` specifies the server for which you want to check the replication state. This server name can be replaced with a variable to make the command more flexible.

### Using a Variable

To replace the server name with a variable, you can modify the command as follows:

```powershell
$serverName = "au-syd-app1"
dfsrdiag replicationstate /member:$serverName
```

This allows you to dynamically assign different server names, making your script adaptable to various environments.

### What It Does

When executed, the command queries the specified server `($serverName)` and returns the current state of DFSR activities. This includes information about which files are currently being replicated and their status. It's an essential tool for administrators who need to monitor DFS replication health in real time.

## Command 2: Listing Replicated Folders with Get-WmiObject

Another crucial aspect of managing DFSR is understanding which folders are being replicated. The Get-WmiObject cmdlet can be used to query this information from the Windows Management Instrumentation (WMI) namespace.

### Basic Usage

```powershell
Get-WmiObject -Namespace "root\MicrosoftDFS" -Query "SELECT * FROM DfsrReplicatedFolderInfo" | Select-Object ReplicatedFolderName, Volume, RootPath
```

This command retrieves all replicated folders on the specified server, providing details such as the folder name, volume, and root path.

### Using a Variable

To replace the server name with a variable, you would incorporate the $serverName variable into a script like this:

```powershell
$serverName = "au-syd-app1"
Invoke-Command -ComputerName $serverName -ScriptBlock {
    Get-WmiObject -Namespace "root\MicrosoftDFS" -Query "SELECT * FROM DfsrReplicatedFolderInfo" | Select-Object ReplicatedFolderName, Volume, RootPath
}
```

Here, Invoke-Command is used to run the WMI query on a remote server specified by $serverName.

### What It Does

This command queries the DFSR information from the WMI namespace and returns details about all replicated folders on the specified server. It's useful for administrators who need to audit or troubleshoot the DFSR configuration.

## Conclusion

Monitoring and managing DFS Replication is critical for ensuring data consistency and availability across your Windows Server infrastructure. By using the `dfsrdiag replicationstate` and `Get-WmiObject` commands, you can effectively check the replication state and review the replicated folders on your servers. Incorporating variables into these commands allows for more flexible and dynamic management, making your administrative tasks more efficient.

## C# Code

To create a basic CLI application in DotNet/C#, use the following boilerplate:

```csharp
using System;
using System.Management;

class Program
{
    static void Main()
    {
        // Define the WMI namespace and query
        string wmiNamespace = @"root\MicrosoftDFS";
        string queryString = "SELECT ReplicatedFolderName, Volume, RootPath FROM DfsrReplicatedFolderInfo";

        // Create a ManagementObjectSearcher to run the WMI query
        ManagementObjectSearcher searcher = new ManagementObjectSearcher(wmiNamespace, queryString);

        // Execute the query and get the results
        foreach (ManagementObject queryObj in searcher.Get())
        {
            // Display the properties of each object returned by the query
            Console.WriteLine("ReplicatedFolderName: {0}", queryObj["ReplicatedFolderName"]);
            Console.WriteLine("Volume: {0}", queryObj["Volume"]);
            Console.WriteLine("RootPath: {0}", queryObj["RootPath"]);
            Console.WriteLine();
        }
    }
}
```
