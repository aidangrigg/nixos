#!/usr/bin/env bash

case "$(printf "kill\nzzz\nreboot\nshutdown\nlock" | dmenu.sh -p powermenu)" in
	kill) ps -u "$USER" -o pid,comm,%cpu,%mem | dmenu.sh -p Kill: | awk '{print $1}' | xargs -r kill ;;
    zzz) systemctl sleep ;;
	reboot) systemctl reboot ;;
	shutdown) shutdown now ;;
	lock) xsecurelock ;;
	*) exit 1 ;;
esac
