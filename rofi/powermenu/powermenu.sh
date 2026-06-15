#!/bin/bash

theme="$HOME/.config/rofi/powermenu/powermenu.rasi"

lock=" Lock"
logout=" Logout"
poweroff=" Poweroff"
reboot=" Reboot"
sleep=" Suspend"

selected_option=$(echo "$poweroff
$lock
$reboot
$sleep
$logout" | rofi -dmenu -i -p "Powermenu:" \
		-theme ${theme})

if [ "$selected_option" == "$lock" ]
then
  hyprlock
elif [ "$selected_option" == "$logout" ]
then
 loginctl terminate-user `valenyqs`
elif [ "$selected_option" == "$poweroff" ]
then
  systemctl poweroff
elif [ "$selected_option" == "$reboot" ]
then
  systemctl reboot
elif [ "$selected_option" == "$sleep" ]
then
  hyprlock & sleep 2 && systemctl suspend
else
  echo "No match"
fi
