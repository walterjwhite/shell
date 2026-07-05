_sway_init() {
  export YDOTOOL_SOCKET=/tmp/.ydotool_socket

  local sway_screen_width=$(swaymsg -t get_outputs | grep -o '"current_mode":{[^}]*}' | grep -m1 '' | sed 's/.*"width":\([0-9]*\).*/\1/')
  local sway_screen_height=$(swaymsg -t get_outputs | grep -o '"current_mode":{[^}]*}' | grep -m1 '' | sed 's/.*"height":\([0-9]*\).*/\1/')
}
