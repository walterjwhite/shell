if [ "$debug" ]; then
  readonly ARGS="$_ARGS --log_debug --traceback"
fi
if [ -n "$_BODY" ]; then
  readonly REQUEST_ARGS="$_REQUEST_ARGS body=$_BODY"
fi

. $_REQUEST

if [ -n "$_DOWNLOAD" ]; then
  local _REQUEST_ARGS="--download --output ${_REQUEST_LOG_FILE}-$_DOWNLOAD"
fi

if [ -n "$_AUTH" ]; then
  readonly ARGS="$_ARGS -a $_AUTH"
fi
if [ -n "$_AUTH_TYPE" ]; then
  readonly ARGS="$_ARGS -A $_AUTH_TYPE"
fi

http $_ARGS $_METHOD $_URL $_PARAMETERS $_REQUEST_ARGS >>$_REQUEST_LOG_FILE
