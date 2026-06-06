#!/bin/bash
if [ "$#" -ne 2 ]; then
	exit 1
fi

ACTION=$1
FILE_PATH=$2

case "$ACTION" in
export)

	if [ "$EUID" -ne 0 ]; then
		echo "root needed"
		exit 1
	fi
	>"$FILE_PATH"
	for f in /etc/NetworkManager/system-connections/*.nmconnection; do
		[ -f "$f" ] || continue
		ssid=$(grep -E "^ssid=" "$f" | cut -d= -f2-)
		psk=$(grep -E "^psk=" "$f" | cut -d= -f2-)
		if [ -n "$ssid" ]; then
			if [ -n "$psk" ]; then
				echo "${ssid},${psk}" >>"$FILE_PATH"
			else
				echo "${ssid}," >>"$FILE_PATH"
			fi
		fi
	done
	;;
import)
	while IFS=',' read -r ssid psk || [ -n "$ssid" ]; do

		if [ -z "$psk" ]; then
			nmcli connection add type wifi con-name "$ssid" ssid "$ssid" autoconnect yes
		else
			nmcli connection add type wifi con-name "$ssid" ssid "$ssid" autoconnect yes wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$psk"
		fi
	done <"$FILE_PATH"
	;;
*)
	exit 1
	;;
esac
