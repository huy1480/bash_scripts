#!/bin/bash

# This script was made when I was frequently travelling and needed to connect to several hotel Wi-Fi
# networks that required the use of portals that conflicted with my static Quad9 DNS servers in
# dhcpcd.

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# For any run, the script will check if the static DNS settings are commented or not. If it isn't
# commented, it'll comment them, and vice versa.

# The logic in this command is backwards, where 1 means nothing was found, and 0 means something was found.
commented=`grep -q "#static domain_name_servers" /etc/dhcpcd.conf; [ $? -eq 0 ] && echo 0 || echo 1`

#
if [ ${commented} == 1 ]; then
	# Disconnect from Mullvad
	mullvad disconnect

	# Comment dhcpcd DNS settings and restart
	sed -i 's/static domain_name_servers=/#static domain_name_servers=/' /etc/dhcpcd.conf
	sed -i 's/nohook/#nohook/' /etc/dhcpcd.conf
	systemctl restart dhcpcd.service

	# Launch iwctl to auth with Wi-Fi
	iwctl

	echo "Please go to http://detectportal.firefox.com/ or http://detectportal.brave-http-only.com/ to authenticate"
elif [ ${commented} == 0 ]; then
	echo "Assuming Wi-Fi was authenticated, restarting dhcpcd..."

	# Uncomment dhcpcd DNS settings and restart
	sed -i 's/#static domain_name_servers=/static domain_name_servers=/' /etc/dhcpcd.conf
	sed -i 's/#nohook/nohook/' /etc/dhcpcd.conf
	systemctl restart dhcpcd.service

	# Reconnect to Mullvad
	mullvad connect

fi
