#!/bin/bash

for archive in *.7z; do
	no_ext=${archive%.*}
	7z e "${no_ext}.7z" -o./"${no_ext}/"
done
