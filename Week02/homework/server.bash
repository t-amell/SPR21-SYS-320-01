#!/bin/bash

# Storyline: Script to create a wireguard server

# Check if server config file exists

if [[ -f "wg0.conf" ]]
then
	echo "The wf0.conf file exists."
	echo -n "Would you like to overwrite it? [y|N] "
	read create_new
	
	if [[ "${create_new}" == "N" || "${create_new}" == "" ]]
	then
		echo "Exiting..."
		exit 0
	elif [[ "${create_new}" == "y" ]]
	then
		echo "Overwriting wg0.conf file."
	else
		echo "Invalid entry."
		exit 1
	fi
else
	# If doesn't exist, would the user like to create it.	
	
	echo "The wg0.conf file does not exist"
	echo -n "Would you like to create it? [y|N] "
	read create_new
	
	if [[ "${create_new}" == "N" || "${create_new}" == "" ]]
	then
		echo "Exiting..."
		exit 0
	elif [[ "${create_new}" == "y" ]]
	then
		echo "Creating new wg0.conf file."
	else
		echo "Invalid entry."
		exit 1
	fi
fi

# Create a private key
prv="$(wg genkey)"


# Create a public key
pub="$(echo ${prv} | wg pubkey)"


# Set the addresses
address="10.254.132.0/24,172.16.28.0/24"


# Set Server IP addresses
ServerAddress="10.254.132.1/24,172.16.28.0/24"


# Set the Listening port
lport="4282"


# Create the format for the client configuration options
peerInfo="# ${address} 198.199.97.163:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"


echo "${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${prv}
" > wg0.conf
