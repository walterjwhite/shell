lib ./add.file.sh
lib ./add.git.sh
lib ./add.other.sh

_prepare() {
	mkdir -p $(dirname $_REFERENCE_PATH)
}

_notes() {
	_read_if "Enter some notes or enter to continue" _NOTES

	if [ -n "$_NOTES" ]; then
		printf '%s\n' "$_NOTES" >>${_REFERENCE_PATH}.notes

		_GIT_PATH="$_GIT_PATH ${_REFERENCE_PATH}.notes"
	fi
}

_add() {
	if [ -f "$1" ]; then
		_reference_name "$1"
		_do_file "$1"
	else
		if [ "$(_is_git $1)" -eq "1" ]; then
			_reference_name "$1"
			_do_git "$1"
		else
			_reference_name_other "$1"
			_do_other "$1"
		fi
	fi

	_GIT_PATH="$_REFERENCE_PATH"
	_notes
	_git_save "+$_REFERENCE_NAME" "$_GIT_PATH"
}

_reference_name() {
	_REFERENCE_NAME=$(basename "$1")
}
