#!/bin/sh

options="Poweroff\nReboot\nLock\nSuspend\nLogout"

chosen=$(echo -e "$options" | fuzzel -d -p "Power: ")

case "$chosen" in
    Poweroff) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Lock) swaylock ;;
    Suspend) systemctl suspend ;;
    Logout) niri msg action quit ;; 
esac
