_ACTUAL_ARGUMENT_COUNT=$#
_DISCOVERED_ARGUMENT_COUNT=$(printf '%s' "$_REQUIRED_ARGUMENTS" | sed -e 's/$/\n/' | tr '|' '\n' | wc -l | awk {'print$1'})

_required_arguments_argument_log_level=_DEBUG

[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _required_arguments_argument_log_level=_WARN

$_required_arguments_argument_log_level "Expecting $_DISCOVERED_ARGUMENT_COUNT, received $# arguments"

_ARG_INDEX=1
_ARGUMENT_LOG_LEVEL=_INFO
while [ $_ARG_INDEX -le $_DISCOVERED_ARGUMENT_COUNT ]; do
	_ARGUMENT_NAME=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_ARG_INDEX}p | sed -e 's/:.*$//')
	_ARGUMENT_MESSAGE=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_ARG_INDEX}p | sed -e 's/^.*://')

	if [ -z "$1" ]; then
		$_required_arguments_argument_log_level "$_ARG_INDEX:$_ARGUMENT_MESSAGE was not provided"
	else
		$_required_arguments_argument_log_level "$_ARG_INDEX:$_ARGUMENT_NAME=$1"
		export $_ARGUMENT_NAME="$1"
		shift
	fi

	_ARG_INDEX=$(($_ARG_INDEX + 1))
done

[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _ERROR "Missing arguments"
unset _ARG_INDEX _ARGUMENT_NAME _ARGUMENT_MESSAGE _required_arguments_argument_log_level

_DISCOVERED_REQUIRED_ARGUMENTS="$_REQUIRED_ARGUMENTS"
unset _REQUIRED_ARGUMENTS

_DEBUG "REMAINING ARGS: $*"
