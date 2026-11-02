#!/bin/bash

# Define the path to the fan control file
FAN_FILE="/proc/acpi/ibm/fan"
THINKPAD_ACPI_FAN_CONTROL_PARAM="/sys/module/thinkpad_acpi/parameters/fan_control"

# --- Prerequisite Checks ---

# Check if the fan control file exists
if [ ! -f "$FAN_FILE" ]; then
    echo "Error: Fan control file '$FAN_FILE' not found."
    echo "Please ensure your system supports ThinkPad ACPI fan control (e.g., 'thinkpad_acpi' module is loaded)."
    exit 1
fi

# Check if thinkpad_acpi module is loaded and fan_control parameter exists
# (This assumes /sys/module/thinkpad_acpi exists if the module is loaded)
if [ ! -f "$THINKPAD_ACPI_FAN_CONTROL_PARAM" ]; then
    echo "Error: 'thinkpad_acpi' module not loaded or 'fan_control' parameter not available."
    echo "Please ensure the 'thinkpad_acpi' module is loaded (e.g., 'sudo modprobe thinkpad_acpi')."
    exit 1
fi

# Check if fan_control is enabled (value is 1)
FAN_CONTROL_STATUS=$(cat "$THINKPAD_ACPI_FAN_CONTROL_PARAM" 2>/dev/null) # Redirect stderr in case of permission issues
if [ "$FAN_CONTROL_STATUS" -ne 1 ]; then
    echo "Error: 'fan_control' for 'thinkpad_acpi' is currently disabled (value is $FAN_CONTROL_STATUS)."
    echo "To enable manual fan control permanently, add the following line to /etc/modprobe.d/thinkpad_acpi.conf:"
    echo "  options thinkpad_acpi fan_control=1"
    echo "Then, reload the module (sudo rmmod thinkpad_acpi && sudo modprobe thinkpad_acpi) or reboot your system."
    exit 1
fi

# --- End Prerequisite Checks ---

# Function to set fan speed using tee
set_fan_speed() {
    # Use `printf` instead of `echo -e` for better portability and safety with tee
    printf "level %s\n" "$1" | sudo tee "$FAN_FILE" > /dev/null
    
    # Check the exit status of the tee command
    if [ $? -eq 0 ]; then
        echo "Fan speed set to $1."
    else
        echo "Failed to set fan speed to $1. An error occurred."
        echo "Current fan status: $(cat "$FAN_FILE" 2>/dev/null)"
    fi
}

# Display menu
while true; do
    echo "" # Add a newline for better readability before the menu
    echo "Fan Control Menu:"
    echo "1) Off (level 0)"
    echo "2) Low Speed (level 2)"
    echo "3) Medium Speed (level 4)"
    echo "4) High Speed (level 7)"
    echo "5) Maximum Speed (disengaged)"
    echo "6) Auto"
    echo "7) Exit"
    
    read -p "Select an option (1-7): " option

    case $option in
        1) set_fan_speed 0 ;;
        2) set_fan_speed 2 ;;
        3) set_fan_speed 4 ;;
        4) set_fan_speed 7 ;;
        5) set_fan_speed "disengaged" ;;
        6) set_fan_speed "auto" ;;
        7) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
