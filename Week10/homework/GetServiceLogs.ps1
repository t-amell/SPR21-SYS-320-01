# Storyline: View all services, check for a specific status, and print the results

function select_status() {

    cls

    # List all Services
    $theServices = Get-Service
    $theServices | Out-Host

    # Create the array to store the status
    $arrStatus = @('all', 'stopped', 'running')

    # Prompt the user for the status to view or quit.

    $readStatus = read-host -Prompt "Please specify a service status or press 'q' to quit the program"

    # Check if the user wants to quit.

    if ($readStatus -match "^[qQ]$") {
        break
    }

    status_check -statusToSearch $readStatus

} # ends the select_status()

function status_check() {

    # String the user types in within the select_status function
    Param([string]$statusToSearch)

    # Search the array for the exact hashtable string
    if ($arrStatus -match $statusToSearch){
        Write-Host -BackgroundColor Green -ForegroundColor White "Please wait, it may take a few moments to retrieve the service entries."
        sleep 2

        # Call the function to view the service.
        view_services -statusToSearch $statusToSearch

    } else {
        Write-Host -BackgroundColor Green -ForegroundColor White "The status specified doesn't exist"

        sleep 2

        select_status
    }

} # ends the status_check()

function view_services() {

    cls

    # Get the services

    if ($statusToSearch -match "all") {
        Get-Service
    } else {
        Get-Service | Where-Object { $_.Status -eq $statusToSearch}
    }

    # Pause the screen and wait until the user is ready to proceed.
    Read-Host -Prompt "Press enter when you are done."

    # Go back to select_status
    select_status

} # ends the view_service()

# Run the select_status as the first function
select_status