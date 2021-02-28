#!/bin/bash

# Storyline: Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then
		echo -e "\e[1;31mThe $1 policy is not compliant. The current policy should be: $2, the current policy is $3."
		echo -e "\e[1;31mREMEDIATION"
		echo -e "\e[1;31m$4"
	else
		echo -e "\e[1;32mThe $1 policy is compliant. The current policy is $3."
	fi
	
}

# Checks for port forward rules
chk_ip_forward=$(sysctl net.ipv4.ip_forward | awk ' { print $3 } ')
checks "IP Forwarding" "0" "${chk_ip_forward}" "Edit: /etc/sysctl.conf\nset: \nnet.ipv4.ip_forward=1\nto\nnet.ipv4.ip_forward=0.\nrun: \n sysctl -w"

chk_ICMP_redirect=$(sysctl net.ipv4.conf.all.send_redirects | awk ' { print $3 } ')
checks "ICMP redirect" "0" "${chk_ICMP_redirect}" "Edit: /etc/sysctl.conf\nset: \nnet.ipv4.conf.all.send_redirects=1\nto\nnet.ipv4.conf.all.send_redirects=0.\nrun: sysctl -w"

chk_crontab=$(grep -r aide /etc/cron.* /etc/crontab)
checks "Crontab" "crontab for root" "${chk_crontab}" "Edit: /etc/crontab\nset: 0 5 * * * /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check\nrun: crontab -u root -e"

chk_cron_hourly=$(stat /etc/cron.hourly | egrep -m 1 Access:)
checks "Cron.hourly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_cron_hourly}" "Edit: /etc/cron.hourly\nSet: chown root:root /etc/cron.hourly\nchmod og-rwx /etc/cron.hourly"

chk_cron_daily=$(stat /etc/cron.daily | egrep -m 1 Access:)
checks "Cron.daily" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_cron_daily}" "Edit: /etc/cron.daily\nSet: chown root:root /etc/cron.daily\nchmod og-rwx /etc/cron.daily"

chk_cron_weekly=$(stat /etc/cron.weekly | egrep -m 1 Access:)
checks "Cron.weekly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_cron_weekly}" "Edit: /etc/cron.weekly\nSet: chown root:root /etc/cron.weekly\nchmod og-rwx /etc/cron.weekly"

chk_cron_monthly=$(stat /etc/cron.monthly | egrep -m 1 Access:)
checks "Cron.monthly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_cron_monthly}" "Edit: /etc/cron.monthly\nSet: chown root:root /etc/cron.monthly\nchmod og-rwx /etc/cron.monthly"

chk_pass=$(stat /etc/passwd | egrep -m 1 Access:)
checks "/etc/passwd" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_pass}" "Edit: /etc/passwd\nSet: chown root:root /etc/passwd\nchmod 644 /etc/passwd"

chk_shadow=$(stat /etc/shadow | egrep -m 1 Access:)
checks "/etc/shadow" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chk_shadow}" "Edit: /etc/shadow\nSet: chown root:shadow /etc/shadow\nchmod o-rwx,g-wx /etc/shadow"

chk_group=$(stat /etc/group | egrep -m 1 Access:)
checks "/etc/group" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_group}" "Edit: /etc/group\nSet: chown root:root /etc/group\nchmod 644 /etc/group"

chk_gshadow=$(stat /etc/gshadow | egrep -m 1 Access:)
checks "/etc/gshadow" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chk_gshadow}" "Edit: /etc/gshadow\nSet: chown root:shadow /etc/gshadow\nchmod o-rwx,g-rw /etc/gshadow"

chk_passwd_dash=$(stat /etc/passwd- | grep -m 1 Access:)
checks "/etc/passwd-" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_passwd_dash}" "Edit: /etc/passwd-\nSet: chown root:root /etc/passwd-\nchmod u-x,go-wx /etc/passwd-"

chk_shadow_dash=$(stat /etc/shadow- | grep -m 1 Access:)
checks "/etc/shadow-" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chk_shadow_dash}" "Edit: /etc/shadow-\nSet: chown root:shadow /etc/shadow-\nchmod o-rwx,g-rw /etc/shadow-"

chk_group_dash=$(stat /etc/group- | grep -m 1 Access:)
checks "/etc/group-" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chk_group_dash}" "Edit: /etc/group-\nSet: chown root:root /etc/group-\nchmod u-x.go-wx /etc/group-"

chk_gshadow_dash=$(stat /etc/gshadow- | grep -m 1 Access:)
checks "/etc/gshadow-" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chk_gshadow_dash}" "Edit: /etc/gshadow-\nSet: chown root:shadow /etc/gshadow-\nchmod o-rwx,g-rw /etc/gshadow-"

chk_legacy_pass=$(grep '^\+:' /etc/passwd)
checks "No legacy shadow entries" "" "${chk_legacy_pass}" "Edit: /etc/passwd\nRemove: Any legacy '+' entries"

# Sudo was necessary as access was denied without it
chk_legacy_shadow=$(sudo grep '^\+:' /etc/shadow)
checks "No legacy shadow entries" "" "${chk_legacy_shadow}" "Edit: /etc/shadow\nRemove: Any legacy '+' entries"

chk_legacy_group=$(grep '^\+:' /etc/group)
checks "No legacy group entries" "" "${chk_legacy_group}" "Edit: /etc/group\nRemove: Any legacy '+' entries"

chk_other_0=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
checks "Root is only UID 0 User" "root" "${chk_other_0}" "Edit: /etc/passwd\nRemove: Users other than root with UID 0 or assign new UID if appropriate"







