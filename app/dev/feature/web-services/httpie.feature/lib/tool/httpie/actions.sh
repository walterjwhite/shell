_httpie_action() {
	if [ -e $1 ]; then
		for _ACTION in $($_REQUEST_KEY/$1 -type f); do
			. $_ACTION
		done
	fi
}
