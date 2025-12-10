_notify() {
	local title=$1
	local message=$2

	zenity --_INFO --text="$_APPLICATION_NAME - $_APPLICATION_CMD - $title\n$message"
}

