#!/bin/bash

# Get current brightness
get_brightness() {
    brightnessctl -m | grep -o '[0-9]*%' | tr -d '%'
}

# Send notification
notify() {
    brightness=$(get_brightness)
    dunstify -a "changebrightness" -u low -i display-brightness -h string:x-dunst-stack-tag:brightness -h int:value:"$brightness" "Brightness: ${brightness}%"
}

# Main script
case $1 in
    up)
        brightnessctl set +5%
        notify
        ;;
    down)
        brightnessctl set 5%-
        notify
        ;;
    *)
        echo "Usage: $0 {up|down}"
        ;;
esac