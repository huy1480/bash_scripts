#!/bin/bash

for archive in *.zip; do
	no_ext=${archive%.*}
	unzip -v "${archive}" -d ./"${no_ext}/"
done
