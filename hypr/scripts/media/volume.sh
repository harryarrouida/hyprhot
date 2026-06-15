#!/bin/bash

# Get current volume and mute status
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

# Send notification
notify() {
    volume=$(get_volume)
    mute=$(get_mute)
    if [ "$mute" == "yes" ]; then
        dunstify -a "changevolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:volume "Volume: Muted"
    else
        dunstify -a "changevolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:volume -h int:value:"$volume" "Volume: ${volume}%"
    fi
}

# Main script
case $1 in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        notify
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        notify
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        notify
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        ;;
esac
