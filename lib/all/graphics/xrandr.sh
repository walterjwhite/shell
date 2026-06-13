_xrandr_init() {
  local xrandr_screen_width=$(xrandr | grep ' connected ' | awk {'print$3'} | head -1 | sed -e 's/+.*//' | cut -f1 -dx)
  local xrandr_screen_height=$(xrandr | grep ' connected ' | awk {'print$3'} | head -1 | sed -e 's/+.*//' | cut -f2 -dx)
}
