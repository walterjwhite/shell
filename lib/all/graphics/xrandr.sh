_xrandr_init() {
	SCREEN_WIDTH=$(xrandr | grep ' connected ' | awk {'print$3'} | head -1 | sed -e 's/+.*//' | cut -f1 -dx)
	SCREEN_HEIGHT=$(xrandr | grep ' connected ' | awk {'print$3'} | head -1 | sed -e 's/+.*//' | cut -f2 -dx)
}
