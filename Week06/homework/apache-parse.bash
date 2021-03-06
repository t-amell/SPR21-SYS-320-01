#!/bin/bash

# Storyline: Script that parses apache logs and creates an IPTables ruleset and Windows firewall rule using powershell

read -p "Please enter an apache log file: " logFile
if [[ ! -f ${logFile} ]]
then
	echo "File Does Not Exist."
	exit 1
fi

badIPList=$(awk '{ print $1 }' ${logFile} | sort -u)

>badIPSIPTables
>badIPSWindows.ps1

for badIP in ${badIPList}
do
	echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${badIP}\" dir=in action=block remoteip=${badIP}" >> badIPSWindows.ps1
	echo "iptables -A INPUT -s ${badIP} -j REJECT" >> badIPSIPTables
done
