#!/bin/bash

read -p "AAC bitrate: " aac_bitrate
read -p "VBR? [Y/n]: " vbr_true

if [ "${vbr_true}" == "N" ] || [ "${vbr_true}" == "n" ]; then
	vbr=""
else
	vbr="-vbr 5"
fi

for mp3 in *.mp3; do
	noExtension=${mp3%.*}
	ffmpeg -i "${mp3}" -c:a aac -b:a "${aac_bitrate}k" $vbr "${noExtension}.m4a"
done
