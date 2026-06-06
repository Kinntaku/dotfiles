#!/bin/bash

if [ "$#" -ne 1 ]; then
	exit 1
fi

TARGET_DIR=$1

for key_file in "$TARGET_DIR"/*.{asc,pub,gpg,key}; do
	[ -f "$key_file" ] || continue
	gpg --import "$key_file"
done
