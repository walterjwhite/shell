_sway_init() {
  export YDOTOOL_SOCKET=/tmp/.ydotool_socket

  local sway_screen_width=$(swaymsg -t get_outputs | jq '.[0].current_mode.width')
  local sway_screen_height=$(swaymsg -t get_outputs | jq '.[0].current_mode.height')
}
