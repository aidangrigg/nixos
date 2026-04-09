#!/usr/bin/env bash

case "$(printf "kill\nzzz\nreboot\nshutdown" | dmenu.sh)" in
	kill) ps -u "$USER" -o pid,comm,%cpu,%mem | dmenu.sh -p Kill: | awk '{print $1}' | xargs -r kill ;;
    zzz) xsecurelock & systemctl suspend ;;
	reboot) systemctl reboot ;;
	shutdown) shutdown now ;;
	*) exit 1 ;;
esac
