_XDOTOOL_INIT() {
	:
}

_XDOTOOL_MOVE() {
	xdotool mousemove $X $Y
}

_XDOTOOL_KEY() {
	xdotool key$2 "$1"
}
