# Storyline: Using WMIObject to gather network adapter information

# Use the Get-WMI cmdlet
# Get-WmiObject -Class Win32_service | select Name, PathName, ProcessID

# Get-WmiObject -list | where { $_.Name -ilike "Win32_[n-o]*" } | Sort-Object

# Get-WmiObject -Class Win32_Account | Get-Member

# Task: Grab the network adapter information using the WMI class
# Get the IP address, default gateway, and DNS servers.
# Get DHCP server.

Get-WmiObject -Class win32_NetworkAdapterConfiguration | Select ServiceName, IPAdress, DHCPEnabled, DHCPServer, DefaultIPGateway, DNSDomain


