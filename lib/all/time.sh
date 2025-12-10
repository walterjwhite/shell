_time_seconds_to_human_readable() {
	_HUMAN_READABLE_TIME=$(printf '%02d:%02d:%02d' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60)))
}

_time_human_readable_to_seconds() {
	case $1 in
	*w)
		_TIME_IN_SECONDS=${1%%w}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600 * 8 * 5))
		;;
	*d)
		_TIME_IN_SECONDS=${1%%d}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600 * 8))
		;;
	*h)
		_TIME_IN_SECONDS=${1%%h}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 3600))
		;;
	*m)
		_TIME_IN_SECONDS=${1%%m}
		_TIME_IN_SECONDS=$(($_TIME_IN_SECONDS * 60))
		;;
	*s)
		_TIME_IN_SECONDS=${1%%s}
		;;
	*)
		_ERROR "$1 was not understood"
		;;
	esac
}

_time_decade() {
	local year=$(date +%Y)

	local _end_year=$(printf '%s' $year | head -c 4 | tail -c 1)
	local _event_decade_prefix=$(printf '%s' "$year" | $_CONF_GNU_GREP -Po "[0-9]{3}")

	if [ "$_end_year" -eq "0" ]; then
		_event_decade_start=${_event_decade_prefix}
		_event_decade_start=$(printf '%s\n' "$_event_decade_start-1" | bc)

		_event_decade_end=${_event_decade_prefix}0
	else
		_event_decade_start=$_event_decade_prefix
		_event_decade_end=$_event_decade_prefix

		_event_decade_end=$(printf '%s\n' "$_event_decade_end+1" | bc)
		_event_decade_end="${_event_decade_end}0"
	fi

	_event_decade_start=${_event_decade_start}1

	printf '%s-%s' "$_event_decade_start" "$_event_decade_end"
}

_current_time() {
	date +$_CONF_LOG_DATE_TIME_FORMAT
}

_current_time_unix_epoch() {
	date +%s
}

_timeout() {
	local timeout=$1
	shift

	local message=$1
	shift

	local timeout_units='s'
	if [ $(printf '%s' "$timeout" | grep -c '[smhd]{1}') -gt 0 ]; then
		unset timeout_units
	fi

	local timeout_level=_ERROR
	[ $_WARN ] && timeout_level=_WARN

	local sudo
	[ -n "$_SUDO_REQUIRED" ] || [ -n "$_SUDO_USER" ] && sudo=_sudo

	$sudo timeout $_OPTIONS $timeout "$@" || {
		local error_status=$?
		local error_message="Other error"
		if [ $error_status -eq 124 ]; then
			error_message="Timed Out"
		fi

		[ $_TIMEOUT_ERR_FUNCTION ] && $_TIMEOUT_ERR_FUNCTION
		$timeout_level "_timeout: $error_message: ${timeout}${timeout_units} - $message ($error_status): $sudo timeout $_OPTIONS $timeout $* ($USER)"
		return $error_status
	}
}
