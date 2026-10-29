#!/bin/bash

# This script was made when I was frequently travelling and needed to connect to several hotel Wi-Fi
# networks that required the use of portals that conflicted with my static Quad9 DNS servers in
# dhcpcd.

# Check for root
if [[ `id -u` != 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

# Check for root utility
if command -v sudo >/dev/null 2>&1; then
	ROOT_UTIL="sudo"
elif command -v doas >/dev/null 2>&1; then
	ROOT_UTIL="doas"
	# Check for the correct environment variable configuration w/ cursed conditional (logic is backwards)
	PERMS_EXIST= `grep -q "permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin}" /etc/doas.conf; [ $? -eq 0 ] && echo || echo 1`
	if [ ${PERMS_EXIST} == 1]; then
		echo "Please add this into etc/doas.conf: permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel"
		echo "Or alternatively, if you want to limit to one user: permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} [USERNAME]"
		exit 1
	fi

else
	echo "Cannot detect sudo or doas"
	exit 1
fi

if [ -z "$1" ]; then
	echo "Usage: [ROOT COMMAND] ./wifi_portal_auth.sh '[WI-FI NETWORK]'"
	exit 1
fi

# Exit function in case any part of the script fails
safe_exit() {
	# Uncomment dhcpcd DNS settings and restart

	echo "Uncommenting DNS settings"
	sed -i 's/#static domain_name_servers=/static domain_name_servers=/' /etc/dhcpcd.conf
	sed -i 's/#nohook/nohook/' /etc/dhcpcd.conf
	echo "Restarting dhcpcd"
	systemctl restart dhcpcd.service

	# Reconnect to Mullvad
	mullvad connect

	exit 1
}

trap safe_exit EXIT

# For any run, the script will check if the static DNS settings are commented or not. If it isn't
# commented, it'll comment them, and vice versa.

# The logic in this command is backwards, where 1 means nothing was found, and 0 means something was found.
commented=`grep -q "#static domain_name_servers" /etc/dhcpcd.conf; [ $? -eq 0 ] && echo 0 || echo 1`
current_user=`logname`

mullvad disconnect

# Comment dhcpcd DNS settings and restart
echo "Commenting DNS settings"
sed -i 's/static domain_name_servers=/#static domain_name_servers=/' /etc/dhcpcd.conf
sed -i 's/nohook/#nohook/' /etc/dhcpcd.conf
echo "Restarting dhcpcd"
systemctl restart dhcpcd.service

# Launch iwctl to auth with Wi-Fi
iwctl station wlan0 scan
echo "Waiting for 10 seconds..."
sleep 10
echo "Attempting to connect..."
iwctl station wlan0 connect "$1"
echo "Done"

# Check for existence of browsers
if [ -x "$(command -v librewolf)" ]; then
	active_browser=librewolf
	portal_link="http://detectportal.firefox.com"
	${ROOT_UTIL} -u $(logname) DISPLAY=$DISPLAY XAUTHORITY=$XAUTHRITY ${active_browser} ${portal_link}
elif [ -x "$(command -v firefox)" ]; then
	active_browser=firefox
	portal_link="http://detectportal.firefox.com"
elif [ -x "$(command -v brave)" ]; then
	active_browser=brave
	portal_link="http://detectportal.brave-http-only.com"
else
	echo "No supported browser is installed. Supported browsers are LibreWolf, Firefox, or Brave"
	safe_exit
fi

echo "${active_browser} ${portal_link}"


