#!/bin/bash

# Storyline: Script to add and delete vpn peers

while getopts 'hdacu:' OPTION ; do
	
	# Adding Switch Cases
	case "$OPTION" in
	
		d) u_del=${OPTION}
		;;
		a) u_add=${OPTION}
		;;
		u) t_user=${OPTARG}
		;;
		c) u_check=${OPTION}
		;;
		h) 
			echo ""
			echo "Usage: $(basename $0) [-a]|[-d][-c] -u username"
			echo ""
			exit 1
		;;
		*)
			echo "Invalid value."
			exit 1
		;;
	esac
	
done

# Check to see if -a and -d are empty or if they are both specificed throw an error
if [[ (${u_del} == "" && ${u_add} == "" && ${u_check} == "") || ((${u_del} != "" && ${u_add} != "") || (${u_del} != "" && ${u_check} != "") || ${u_add} != "" && ${u_check} != "") ]]
then
	echo "Please specify -a, -d, or -c and -u username."
	exit 1
fi

#Check to ensure -u is specified
if [[ (${u_del} != "" || ${u_add} != "" || ${u_check} != "") && ${t_user} == "" ]]
then
	echo "Please specifiy a user (-u)!"
	echo "Usage: $(basename $0) [-a]|[-d][-c] -u username"
	exit 1
fi

# Delete a user
if [[ ${u_del} ]]
then
	echo "Deleting user..."
	sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf
	rm ${t_user}-wg0.conf
fi

# Add a user
if [[ ${u_add} ]]
then
	echo "Creating user..."
	bash peer.bash ${t_user}
fi

# Check if user exists
if [[ ${u_check} ]]
then
	# Count User Begins (Using entire beginning statement removes duplicates)
	count=$(grep -c "# ${t_user} begin" wg0.conf)
	
	# If one was counted, Show it exists
	if [[ ${count} > 0 ]]
	then
		echo "${t_user} Exists!"
	else
		echo "${t_user} Does Not Exist!"
	fi
fi

