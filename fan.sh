#!/bin/bash

# Check if the fan control file exists
if [ ! -f /proc/acpi/ibm/fan ]; then
    echo "Fan control not available. Please check if your system supports it."
    exit 1
fi

# Function to set fan speed using tee
set_fan_speed() {
    echo -e "level $1" | sudo tee /proc/acpi/ibm/fan > /dev/null
    echo "Fan speed set to $1."
}

# Display menu
while true; do
    echo "Fan Control Menu:"
    echo "1) Off"
    echo "2) Low Speed"
    echo "3) Medium Speed"
    echo "4) High Speed"
    echo "5) Maximum Speed (disengaged)"
    echo "6) Auto"
    echo "7) Exit"
    
    read -p "Select an option (1-7): " option

    case $option in
        1) set_fan_speed 0 ;;
        2) set_fan_speed 2 ;;
        3) set_fan_speed 4 ;;
        4) set_fan_speed 7 ;;
        5) set_fan_speed "disengaged" ;; # Set maximum speed to disengaged
        6) set_fan_speed "auto" ;;        # Set to auto mode
        7) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
