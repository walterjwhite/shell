readonly ACTUAL_ARGUMENT_COUNT=$#
readonly DISCOVERED_ARGUMENT_COUNT=$(printf '%s' "$REQUIRED_ARGUMENTS" | sed -e 's/$/\n/' | tr '|' '\n' | wc -l | awk {'print$1'})

[ $ACTUAL_ARGUMENT_COUNT -lt $DISCOVERED_ARGUMENT_COUNT ] && log_warn "expecting $DISCOVERED_ARGUMENT_COUNT, received $# arguments"

arg_index=1
while [ $arg_index -le $DISCOVERED_ARGUMENT_COUNT ]; do
  _argument_name=$(printf '%s' "$REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${arg_index}p | sed -e 's/:.*$//')
  _argument_message=$(printf '%s' "$REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${arg_index}p | sed -e 's/^.*://')

  if [ -z "$1" ]; then
    log_warn "$arg_index:$_argument_message was not provided"
  else
    log_debug "$arg_index:$_argument_name=$1"
    eval "$_argument_name=\"$1\""
    shift
  fi

  arg_index=$(($arg_index + 1))
done

[ $ACTUAL_ARGUMENT_COUNT -lt $DISCOVERED_ARGUMENT_COUNT ] && exit_with_error "missing arguments"
unset arg_index _argument_name _argument_message

readonly DISCOVERED_REQUIRED_ARGUMENTS="$REQUIRED_ARGUMENTS"

log_debug "remaining args: $*"
