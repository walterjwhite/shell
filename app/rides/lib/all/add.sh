_exists() {
	if [ ! -e $_FILE ]; then
		return
	fi

	if [ $(grep -c "^$_DATE|$_INDEX|$_BIKE" $_FILE) -gt 0 ]; then
		_ERROR "Entry already exists, please double-check: $_DATE|$_INDEX|$_BIKE - $_FILE"
	fi
}

_file() {
	_YEAR=$(printf '%s' $_DATE | head -c 4)
	_decade

	_FILE=$_PROJECT_PATH/activity/$_DECADE/$_YEAR.csv
}

_decade() {
	_end_year=$(printf '%s' $_YEAR | head -c 4 | tail -c 1)
	_event_decade_prefix=$(printf '%s' "$_YEAR" | head -c 3)

	if [ "$_end_year" -eq "0" ]; then
		_event_decade_start=$(($_event_decade_prefix - 1))
		_event_decade_end=${_event_decade_prefix}0
	else
		_event_decade_start=$_event_decade_prefix
		_event_decade_end=$(($_event_decade_prefix + 1))
		_event_decade_end="${_event_decade_end}0"
	fi

	_event_decade_start=${_event_decade_start}1

	_DECADE=${_event_decade_start}-${_event_decade_end}
}
