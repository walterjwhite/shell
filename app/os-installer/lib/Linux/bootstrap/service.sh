_start_service() {
	rc-service $1 start
}

_stop_service() {
	rc-service $1 stop
}
