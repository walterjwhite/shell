_time_delay() {
	local current_epoch_time=$(date +%s)

	_FUTURE_EPOCH_TIME=$(date -d "$EXECUTION_TIME" +%s)

	local delay=$(($_FUTURE_EPOCH_TIME - $current_epoch_time))

	[ $delay -lt 0 ] && {
		case $EXECUTION_TIME in
		[0-2][0-9]:[0-5][0-9]) ;;
		[0-2][0-9]:[0-5][0-9]:[0-5][0-9]) ;;
		*)
			_ERROR "date/time has already passed: $EXECUTION_TIME"
			;;
		esac

		_WARN "time already passed, running immediately"
		return
	}

	_INFO "waiting ${delay}s"
	sleep $delay &

	wait $!
}

_time_delay_duration() {
	[ -z "$1" ] && return 1

	local delay=0
	case $1 in
	*h)
		delay=${1%h}
		delay=$(($delay * 3600))
		;;
	*m)
		delay=${1%m}
		delay=$(($delay * 60))
		;;
	*s)
		delay=${1%s}
		;;
	*)
		delay=$1
		;;
	esac

	[ $delay -le 0 ] && _ERROR "computed delay < 0"

	_DETAIL "waiting ${delay}s"
	sleep $delay &

	wait $!
}
