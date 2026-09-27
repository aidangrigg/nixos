#!/usr/bin/env bash

date=$(date +"%A, %d/%m/%y [%H:%M]")
bat_cap=$(cat /sys/class/power_supply/BAT1/capacity)
bat_status=$(cat /sys/class/power_supply/BAT1/status)

notify-send -a "Info" -t 3000 "System Info" "Time: ${date}\nBattery: ${bat_status}, at ${bat_cap}%"
