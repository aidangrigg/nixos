#!/usr/bin/env bash

wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
status=$(echo "$status" | awk '{print $3}')

if [ -z "$status" ]
then
    notify-send -t 1000 -a 'wp-vol' "Unmuted"
else
    notify-send -t 1000 -a 'wp-vol' "Muted"
fi

