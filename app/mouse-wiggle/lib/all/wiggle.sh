_wiggle() {
	X=$(shuf -i 0-$SCREEN_WIDTH -n 1)
	Y=$(shuf -i 0-$SCREEN_HEIGHT -n 1)
	DELAY=$(shuf -i 0-$_CONF_MOUSE_WIGGLE_STEP_WAIT -n 1)

	_DETAIL "moving mouse to: $X,$Y"
	${_CONF_MOUSE_WIGGLE_UI_AUTOMATION_PROVIDER}_move $X $Y

	_DETAIL "pressing: $_CONF_MOUSE_WIGGLE_KEY"
	${_CONF_MOUSE_WIGGLE_UI_AUTOMATION_PROVIDER}_key $_CONF_MOUSE_WIGGLE_KEY

	_DETAIL "sleeping ${DELAY}s"
	sleep $DELAY

	printf '\n'
}
