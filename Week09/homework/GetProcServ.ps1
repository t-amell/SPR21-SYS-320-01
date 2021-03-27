# Storyline: Using the Get-process and Get-service
Get-Process | Select ProcessName, ID, Path | Export-Csv `
-Path "C:\Users\Trevo\Desktop\myProcesses.csv" -NoTypeInformation

Get-Service | Where-Object { $_.Status -eq "Running"} | `
Select ServiceName, DisplayName, DependentServices, ServiceType, Status | `
Export-csv -Path "C:\Users\Trevo\Desktop\myServices.csv" -NoTypeInformation
