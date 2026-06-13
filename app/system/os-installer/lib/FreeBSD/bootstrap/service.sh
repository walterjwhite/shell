_start_service() {
  service $1 onestart
}

_stop_service() {
  service $1 onestop
}
