#!/bin/bash

CONFIG_FILE="$DOTFILES/config/niri/config.kdl"
TARGET_LINE='mode "1920x1080@165.003006"'

sed -i "s|^\([[:space:]]*\)\(${TARGET_LINE}\)|\1// \2|" "$CONFIG_FILE"
sleep 1
sed -i "s|^\([[:space:]]*\)// [[:space:]]*\(${TARGET_LINE}\)|\1\2|" "$CONFIG_FILE"
sleep 2
wlr-randr --output eDP-1 --off
