lib git/data.app.sh

cfg git


_target() {
	date +%Y/%m/%d/%H.%M.%S
}

_movies_git() {
	_git_save "$_ACTION - $_MOVIE_ID" "$@"
}

_movies_decade() {
	_end_year=$(printf '%s' $_YEAR | head -c 4 | tail -c 1)
	_event_decade_prefix=$(printf '%s' "$_YEAR" | $_CONF_GNU_GREP -Po "[0-9]{3}")

	if [ "$_end_year" -eq "0" ]; then
		_event_decade_start=${_event_decade_prefix}
		_event_decade_start=$(printf '%s' "$_event_decade_start-1" | bc)

		_event_decade_end=${_event_decade_prefix}0
	else
		_event_decade_start=$_event_decade_prefix
		_event_decade_end=$_event_decade_prefix

		_event_decade_end=$(printf '%s' "$_event_decade_end+1" | bc)
		_event_decade_end="${_event_decade_end}0"
	fi

	_event_decade_start=${_event_decade_start}1

	_DECADE=${_event_decade_start}-${_event_decade_end}
}
