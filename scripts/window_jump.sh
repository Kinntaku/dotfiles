#!/usr/bin/env bash

RAW_JSON=$(niri msg -j windows)

WINDOW_LIST=$(echo "$RAW_JSON" | grep -oE '"id":[0-9]+|"title":"[^"]*"|"app_id":"[^"]*"' | sed -E '
    N;N;
    s/"id":([0-9]+).*"title":"(.*)".*"app_id":"(.*)"/\2 [\3] | \1/
    s/"title":"(.*)".*"app_id":"(.*)".*"id":([0-9]+)/\1 [\2] | \3/
')

CHOICE=$(echo "$WINDOW_LIST" | fuzzel --dmenu -p "windows: " -i)

[ -z "$CHOICE" ] && exit 0

WINDOW_ID="${CHOICE##*| }"
if [ -n "$WINDOW_ID" ]; then
	niri msg action focus-window --id "$WINDOW_ID"
fi
