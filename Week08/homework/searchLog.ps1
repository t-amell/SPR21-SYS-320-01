# Storyline: Review the Security Event Log

# Directory to save files

$myDir = "C:\Users\Trevo\Desktop\"

#List all the available windows Event logs
Get-EventLog -List

# Create a prompt to allow user to select the log to view
$readLog = Read-Host -Prompt "Please select a log to review from the list above"

# Create prompt to get keyword/phrase from user to search on
$searchFor = Read-Host -Prompt "Please specify a search term to find within the $readLog list"

#Print the results for the log
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -ilike "*$searchFor*" } | export-csv -NoTypeInformation `
-Path "$myDir\securityLog.csv"