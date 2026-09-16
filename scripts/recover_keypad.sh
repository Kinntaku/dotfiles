#!/bin/bash

TARGET_FILE="/usr/share/X11/xkb/symbols/keypad"

if [ "$EUID" -ne 0 ]; then
  echo "sudo needed!"
  exit 1
fi

declare -A replacements=(
    ["KP_Home"]="KP_7"
    ["KP_Up"]="KP_8"
    ["KP_Prior"]="KP_9"       
    ["KP_Page_Up"]="KP_9"
    ["KP_Left"]="KP_4"
    ["KP_Begin"]="KP_5"      
    ["KP_Right"]="KP_6"
    ["KP_End"]="KP_1"
    ["KP_Down"]="KP_2"
    ["KP_Next"]="KP_3"        
    ["KP_Page_Down"]="KP_3"
    ["KP_Insert"]="KP_0"
    ["KP_Delete"]="KP_Decimal"
)

SED_EXPR=""
for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    SED_EXPR="${SED_EXPR}s/\\b${old}\\b/${new}/g; "
done

sed -i -e "$SED_EXPR" "$TARGET_FILE"

