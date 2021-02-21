#!/bin/bash

# Storyline: Creating Blocklist for various firewalls

while getopts 'hicnwmrd' OPTION ; do
	
	# Adding Switch Cases
	case "$OPTION" in
		i) 
			$(:> badIPs.iptables)
			for eachIP in $(cat list-bad-ips.txt)
			do
				echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPs.iptables
			done
			exit 0
		;;
		c) 
			# Rule Found: https://support.hostway.com/hc/en-us/articles/360001259000-How-to-add-a-drop-rule-to-a-Cisco-ASA
			$(:> badIPs.cisco)
			echo "object-group network DenyIP" | tee -a badIPs.cisco
			for eachIP in $(cat list-bad-ips.txt)
			do
				echo "network-object host ${eachIP}" | tee -a badIPs.cisco
			done
			echo "access-list outside_access_in extended deny IP object-group DenyIP" | tee -a badIPs.cisco
			exit 0
		;;
		n) 
			# Rule Found: https://www.juniper.net/documentation/en_US/junos/topics/reference/configuration-statement/security-edit-ip-block.html
			# I don't think this is particularly correct but there's so little documentation I could find on this
			$(:> badIPs.netscreen)
			for eachIP in $(cat list-bad-ips.txt)
			do
				echo "ip-block ${eachIP}" | tee -a badIPs.netscreen
			done
			exit 0
		;;
		\w) 
			# Rule Found: https://www.thewindowsclub.com/block-ip-or-a-website-using-powershell-in-windows
			$(:> badIPs.windows)
			for eachIP in $(cat list-bad-ips.txt)
			do
				echo "New-NetFirewallRule -DisplayName 'Drop-${eachIP}' -Direction Outbound –LocalPort Any -Protocol TCP -Action Block -RemoteAddress ${eachIP}" | tee -a badIPs.windows
			done
			exit 0
		;;
		m)
			$(:> badIPs.conf)
			for eachIP in $(cat list-bad-ips.txt)
			do
				echo "block in from ${eachIP} to any" | tee -a badIPs.conf
			done
			exit 0
		;;
		r)
			if [[ -f /tmp/targetedthreats.csv ]]
			then
				read -p "The Cisco URL filters file exists, would you like to download it again?[y|N]" choice
				case "${choice}" in
	
					y|Y) wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
					;;
					n|N) echo "Not downloading again..."
					;;
				esac
				grep 'domain' /tmp/targetedthreats.csv | tee list-bad-domains.txt
				cut -d "," -f 2 list-bad-domains.txt | sort -u | tee list-bad-domains.txt
			else
				wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
			fi
			exit 0
		;;
		d)
			if [[ -f list-bad-domains.txt ]]
			then
				$(:> badURLs.cisco)
				echo "class-map match-any BAD_URLS" | tee -a badURLs.cisco
				for eachDom in $(cat list-bad-domains.txt)
				do
					echo "match protocol http host ${eachDom}" | tee -a badURLs.cisco
				done
				exit 0
			fi
		;;
		h) 
			echo ""
			echo "Usage: $(basename $0) [-i][-c][-n][-w][-m][-d] Create inbound drop rule for respective firewall"
			echo "Iptables, Cisco, Netscreen, Windows Firewall, Mac OS X, Cisco Domain URL"
			echo "[r] Create Cisco URL filter rule"
			echo ""
			exit 0
		;;
		*)
			echo "Invalid value."
			exit 1
		;;
	esac
	
done

if [[ -f /tmp/emerging-drop.suricata.rules ]]
then
	read -p "The emerging threats file exists, would you like to download it again?[y|N]" choice
	case "${choice}" in
	
		y|Y) wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules
		;;
		n|N) echo "Not downloading again..."
		;;
		*) 
			echo "Invalid entry."
			exit 1
		;;
	esac
fi

egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee list-bad-ips.txt

