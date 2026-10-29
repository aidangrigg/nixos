#!/usr/bin/env bash

case "$(printf "kill\nzzz\nreboot\nshutdown\nlock" | dmenu.sh -p powermenu)" in
	kill) ps -u "$USER" -o pid,comm,%cpu,%mem | dmenu.sh -p Kill: | awk '{print $1}' | xargs -r kill ;;
	zzz) loginctl lock-session && xset dpms force off ;;
	reboot) systemctl reboot ;;
	shutdown) shutdown now ;;
	lock) loginctl lock-session ;;
	*) exit 1 ;;
esac
