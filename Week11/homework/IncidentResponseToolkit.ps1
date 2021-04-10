# Storyline: Retrieved artifacts for incident toolkit to export and zip in a readable format

# Get the user determined Path
$readPath = read-host -Prompt "Please specify a path to save the retrieved data"
$truePath = "$readPath\Generated Data"

# Create directory in path, force overwrite if exists
New-Item -Name "Generated Data" -Path $readPath -ItemType "directory" -Force

# Export all of the retrieved data to respective csv files within directory
Export-Retrieved-Data -Output (Get-Process | Select-Object Name, Path) -FileName "processes.csv"
Export-Retrieved-Data -Output (Get-WmiObject -Class Win32_Service | Select-Object Name, DisplayName, PathName) -FileName "services.csv"
Export-Retrieved-Data -Output (Get-NetTCPConnection) -FileName "tcp.csv"
Export-Retrieved-Data -Output (Get-WmiObject -Class Win32_UserAccount) -FileName "userInfo.csv"
Export-Retrieved-Data -Output (Get-WmiObject -Class Win32_NetworkAdapterConfiguration) -FileName "netAdapt.csv"

# See if malware disabled any rule entries
Export-Retrieved-Data -Output (Get-NetFirewallRule) -FileName "firewallRule.csv"

# You can get the task scheduler since it can be used by malware to run malicious events
Export-Retrieved-Data -Output (Get-ScheduledTask) -FileName "scheduled.csv"

# Shows you all installed software to check for suspicious installs
Export-Retrieved-Data -Output (Get-WmiObject -ClassName Win32_Product | `
 select-object Name, Version, Vendor, InstallDate, InstallSource, PackageName, LocalPackage) -FileName "software.csv"

# This shows you the windows registry for windows and applications since they can store malware in it
Export-Retrieved-Data -Output (Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion) `
-FileName "registry.csv"

# Recursively create hash for each file in directory and export
Export-Retrieved-Data -Output (Get-ChildItem -Path "$truePath" -Recurse -File -Exclude "hash.csv" | Get-FileHash) -FileName "hash.csv"

Compress-Data

function Export-Retrieved-Data{
    param(
        $Output, $FileName
    )
    $Output | Export-Csv -Path "$truePath\$Filename" -NoTypeInformation
}

function Compress-Data {
    Compress-Archive -Path $truePath\* -DestinationPath "$readPath\Archived.zip" -Force
    Get-ChildItem -Path "$readPath\Archived.zip" -File | Get-FileHash | `
    Export-Csv -Path "$readPath\archivedHash.csv" -NoTypeInformation
}
