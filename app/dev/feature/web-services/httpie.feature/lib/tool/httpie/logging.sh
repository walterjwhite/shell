_REQUEST_TIMESTAMP=$(date +%Y/%m/%d/%H.%M.%S)
_REQUEST_LOG_FILE=.data/$_REQUEST_TIMESTAMP

mkdir -p $(dirname $_REQUEST_LOG_FILE)
if [ -z "$_NO_LOG_ENV" ]; then
	env >$_REQUEST_LOG_FILE
	printf '%s' "--" >>$_REQUEST_LOG_FILE
fi
