trap '_exit_on_hup $LINENO' 1
trap '_exit_on_int $LINENO' 2
trap '_exit_on_quit $LINENO' 3
trap '_exit_on_illegal $LINENO' 4
trap '_exit_on_abort $LINENO' 6
trap '_exit_on_alarm $LINENO' 14
trap '_exit_on_term $LINENO' 15

trap exit_with_success 0
