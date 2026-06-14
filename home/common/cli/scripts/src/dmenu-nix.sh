#!/usr/bin/env bash

case "$(printf "update flake\nrebuild switch\nhome manager switch\n" | dmenu.sh -p "nix")" in
	'update flake')
        if output=$(nix flake update --flake ~/nix --commit-lock-file 2>&1); then
            notify-send "Flake update successful!"
        else
            notify-send -u critical "Flake update failed" "$output"
        fi ;;
    'rebuild switch')
        if output=$(nh os switch --no-nom ~/nix 2>&1); then
            notify-send "Rebuild succeeded" "$output"
        else
            notify-send -u critical "Rebuild failed :(" "$output"
        fi;;
	'home manager switch')
        if output=$(nh home switch --no-nom --configuration "$HOSTNAME" ~/nix 2>&1); then
            notify-send "Home manager switch succeeded" "$output"
        else
            notify-send -u critical "Home manager switch failed..." "$output"
        fi;;
	'clean all')
        if output=$(pkexec nh clean all 2>&1); then
            notify-send "Clean successful!"
        else
            notify-send -u critical "Clean failed..." "$output"
        fi;;

	*) exit 1 ;;
esac
