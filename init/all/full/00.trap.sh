_is_backgrounded && _BACKGROUNDED=1
_init_logging

unset _DEFERS _EXIT

_APPLICATION_START_TIME=$(date +%s)

_APPLICATION_CMD=$(basename $0)

trap _on_hup 1
trap _on_int 2
trap _on_quit 3
trap _on_illegal 4
trap _on_abort 6
trap _on_alarm 14
trap _on_term 15
trap _success 0
