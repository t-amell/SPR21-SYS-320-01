# Storyline: View the event logs, check for a valid log, and print the results

function select_log() {

    cls
    # List all event logs
    $theLogs = Get-EventLog -list | select Log
    $theLogs | Out-Host

    # Initialize the array to store the logs
    $arrLog = @()

    foreach($tempLog in $theLogs) {

        # Add each log to the array
        # NOTE: These are stored in the array as a hashtable in the format:
        # @(Log=LOGNAME)
        $arrLog += $tempLog

    }

    # Prompt the user for the log to view or quit.

    $readLog = read-host -Prompt "Please enter a log from the list above or 'q' to quit the program"

    # Check if the user wants to quit.

    if ($readLog -match "^[qQ]$") {
        break
    }

    log_check -logToSearch $readLog

} # ends the select_log()

function log_check() {

    # String the user types in within the select_log function
    Param([string]$logToSearch)

    # Format the user's input
    $theLog = "^@{Log=" + $logToSearch + "}$"

    # Search the array for the exact hashtable string
    if ($arrLog -match $theLog){
        Write-Host -BackgroundColor Green -ForegroundColor White "Please wait, it may take a few moments to retrieve the log entries."
        sleep 2

        # Call the function to view the log.
        view_log -logToSearch $logToSearch

    } else {
        Write-Host -BackgroundColor Green -ForegroundColor White "The log specified doesn't exist"

        sleep 2

        select_log
    }

} # ends the log_check()

function view_log() {

    cls

    # Get the logs
    Get-EventLog -Log $logToSearch -Newest 10 -After "1/18/2020"

    # Pause the screen and wait until the user is ready to proceed.
    Read-Host -Prompt "Press enter when you are done."

    # Go back to select_log
    select_log

} # ends the view_log()

# Run the select_log as the first function
select_log