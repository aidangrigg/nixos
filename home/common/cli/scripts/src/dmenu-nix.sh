#!/usr/bin/env bash
set -euo pipefail

menu=$(printf "update flake\nrebuild switch\nhome manager switch\n" \
  | dmenu.sh -p "nix")

notify() {
    local title="$1"
    local body="$2"
    local urgency="${3:-normal}"

    local clean
    clean=$(echo "$body" \
           | sed -r 's/\x1B\[[0-9;]*[mK]//g')

    notify-send -a "nix" -u "$urgency" "$title" "$clean"
}

run_cmd() {
    local title_ok="$1"
    local title_fail="$2"
    shift 2

    local output
    if output="$("$@" 2>&1)"; then
        notify "$title_ok" "$output" normal
    else
        notify "$title_fail" "$output" critical
        return 1
    fi
}

case "$menu" in
    "update flake")
        run_cmd \
            "Flake update succeeded" \
            "Flake update failed" \
            nix flake update --flake ~/nix --commit-lock-file
        ;;

    "rebuild switch")
        run_cmd \
            "NixOS rebuild succeeded" \
            "NixOS rebuild failed" \
            nh os switch --no-nom ~/nix
        ;;

    "home manager switch")
        run_cmd \
            "Home Manager switch succeeded" \
            "Home Manager switch failed" \
            nh home switch --no-nom --configuration "$HOSTNAME" ~/nix
        ;;
    *)
        exit 0
        ;;
esac
