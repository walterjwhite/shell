if [ "$_DEBUG" ]; then
	_ARGS="$_ARGS --debug --traceback"
fi
if [ -n "$_BODY" ]; then
	_REQUEST_ARGS="$_REQUEST_ARGS body=$_BODY"
fi

. $_REQUEST

if [ -n "$_DOWNLOAD" ]; then
	_REQUEST_ARGS="--download --output ${_REQUEST_LOG_FILE}-$_DOWNLOAD"
fi

if [ -n "$_AUTH" ]; then
	_ARGS="$_ARGS -a $_AUTH"
fi
if [ -n "$_AUTH_TYPE" ]; then
	_ARGS="$_ARGS -A $_AUTH_TYPE"
fi

http $_ARGS $_METHOD $_URL $_PARAMETERS $_REQUEST_ARGS >>$_REQUEST_LOG_FILE
