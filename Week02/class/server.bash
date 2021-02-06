#!/bin/bash

# Storyline: Script to create a wireguard server


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
#PostUP = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${prv}
" > wg0.conf

