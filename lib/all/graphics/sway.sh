_sway_init() {
	export YDOTOOL_SOCKET=/tmp/.ydotool_socket

	SCREEN_WIDTH=$(swaymsg -t get_outputs | jq '.[0].current_mode.width')
	SCREEN_HEIGHT=$(swaymsg -t get_outputs | jq '.[0].current_mode.height')
}
