#!/bin/bash

# Source the Pywal colors
source "$HOME/.cache/wal/colors.sh"

# Define the output files
HYPR_COLORS_FILE="$HOME/.cache/wal/colors-hyprland.conf"
DUNST_CONFIG_FILE="$HOME/.config/dunst/dunstrc"

# Generate Dunst config
cat <<EOF > "$DUNST_CONFIG_FILE"
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x10
    scale = 0
    notification_limit = 0
    
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    
    indicate_hidden = yes
    transparency = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 2
    frame_color = "$color1"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    
    font = Hack Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    
    icon_position = left
    min_icon_size = 0
    max_icon_size = 64
    
    sticky_history = yes
    history_length = 20
    
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 6
    ignore_dbusclose = false
    
    force_xwayland = false
    force_xinerama = false
    
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "$background"
    foreground = "$foreground"
    timeout = 10

[urgency_normal]
    background = "$background"
    foreground = "$foreground"
    timeout = 10

[urgency_critical]
    background = "$background"
    foreground = "$foreground"
    frame_color = "$color1"
    timeout = 0
EOF

# Restart dunst to apply changes
killall dunst
dunst &

# Generate Hyprland colors
# Remove the '#' from the beginning of the hex codes and add 'ff' for opacity
printf "
# Colors from Pywal
\$background = rgba(%sff)
\$foreground = rgba(%sff)
\$color0 = rgba(%sff)
\$color1 = rgba(%sff)
\$color2 = rgba(%sff)
\$color3 = rgba(%sff)
\$color4 = rgba(%sff)
\$color5 = rgba(%sff)
\$color6 = rgba(%sff)
\$color7 = rgba(%sff)
\$color8 = rgba(%sff)
\$color9 = rgba(%sff)
\$color10 = rgba(%sff)
\$color11 = rgba(%sff)
\$color12 = rgba(%sff)
\$color13 = rgba(%sff)
\$color14 = rgba(%sff)
\$color15 = rgba(%sff)
" \
"${background:1}" "${foreground:1}" "${color0:1}" "${color1:1}" "${color2:1}" "${color3:1}" "${color4:1}" "${color5:1}" "${color6:1}" "${color7:1}" "${color8:1}" "${color9:1}" "${color10:1}" "${color11:1}" "${color12:1}" "${color13:1}" "${color14:1}" "${color15:1}" > "$HYPR_COLORS_FILE"
