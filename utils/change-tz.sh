#!/bin/bash

# script created when i went to a concert in new orleans and wanted something to
# make my life a tiny bit more convenient when i went back to EST land

read -p "[E]astern (UTC-5)/[C]entral (UTC-6)/[J]apan (UTC+9): " time_zone

if [ "${time_zone}" == "E" ] || [ "${time_zone}" == "e" ]; then
	doas ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
elif [ "${time_zone}" == "C" ] || [ "${time_zone}" == "C" ]; then
	doas ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
elif [ "$(time_zone)" == "J" ] || [ "$(time_zone)" == "j" ]; then
	doas ln -sf /usr/share/zoneinfo/Japan /etc/localtime
else
	echo "Invalid input! Please try again..."
fi
