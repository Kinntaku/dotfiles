
MENU="rofi -dmenu -p Power"

options="Suspend\nSleep\nRestart\nShutdown\nExit"

chosen=$(echo -e "$options" | $MENU)

case "$chosen" in
    Suspend)
        systemctl suspend
        ;;
    Sleep)
        systemctl hibernate
        ;;
    Restart)
        reboot
        ;;
    Shutdown)
        poweroff
        ;;
    Exit)
        pkill dwm
        ;;
    *)
        exit 0
        ;;
esac