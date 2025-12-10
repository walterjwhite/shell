_is_backgrounded && _BACKGROUNDED=1
_init_logging

unset _DEFERS _EXIT

_APPLICATION_START_TIME=$(date +%s)

_APPLICATION_CMD=$(basename $0)
