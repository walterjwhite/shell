_YDOTOOL_INIT() {
	export YDOTOOL_SOCKET=/tmp/.ydotool_socket
}

_YDOTOOL_MOVE() {
	ydotool mousemove -x $X -y $Y
}

_YDOTOOL_KEY() {
	local key
	local key_action

	case $1 in
	ctrl)
		key=17
		;;
	*)
		_ERROR "Unmapped key: $1"
		;;
	esac
	case $2 in
	down)
		key_action=1
		;;
	up)
		key_action=0
		;;
	*)
		_ERROR "Unmapped key action: $2"
		;;
	esac

	ydotool key "$key:$key_action"
}
