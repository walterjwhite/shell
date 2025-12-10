_link() {
	_sudo ln -s $1 $2
}

_install_link() {
	_link $1 $2 &&
		printf '%s\n' "$2" | _append "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files"
}
