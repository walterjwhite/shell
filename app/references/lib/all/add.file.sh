_do_file() {
	_REFERENCE_PATH=$_PROJECT_PATH/$_KEY/files/$_REFERENCE_NAME
	_prepare

	cp "$1" $_REFERENCE_PATH
}
