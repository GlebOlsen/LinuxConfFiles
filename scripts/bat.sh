#!/bin/bash

POWER_SUPPLY_PATH="/sys/class/power_supply"

find_batteries() {
    local bats=()
    for d in "$POWER_SUPPLY_PATH"/BAT*; do
        if [ -d "$d" ]; then bats+=("$(basename "$d")"); fi
    done
    echo "${bats[@]}"
}

set_threshold() {
    local bat="$1"
    local thres="$2"
    local f="$POWER_SUPPLY_PATH/$bat/charge_control_end_threshold"

    if [ ! -f "$f" ]; then
        echo "Skipping $bat: Control file not found."
        return 1
    fi

    echo "$thres" | sudo tee "$f" > /dev/null
    if [ $? -eq 0 ]; then
        echo "$bat: Set to $thres%."
    else
        echo "$bat: Failed to set $thres%. (Permissions/Support?)"
        return 1
    fi
}

bats=($(find_batteries))

if [ ${#bats[@]} -eq 0 ]; then
    echo "No batteries found. Exiting."
    exit 1
fi

echo "Detected batteries: ${bats[@]}"

while true; do
    echo ""
    echo "Set max charge for all detected batteries:"
    echo "1) 80%"
    echo "2) 85%"
    echo "3) 100% (Default)"
    echo "4) Exit"
    read -p "Enter choice (1-4): " choice

    case $choice in
        1) thres=80 ;;
        2) thres=85 ;;
        3) thres=100 ;;
        4) echo "Exiting."; exit 0 ;;
        *) echo "Invalid choice."; continue ;;
    esac

    echo "Applying $thres%..."
    for b in "${bats[@]}"; do
        set_threshold "$b" "$thres"
    done

    echo ""
    echo "Note: This setting is NOT persistent across reboots."
    echo "Consider TLP or a systemd service for persistence."
    read -p "Set another threshold? (y/N): " cont
    if [[ ! "$cont" =~ ^[Yy]$ ]]; then exit 0; fi
done
