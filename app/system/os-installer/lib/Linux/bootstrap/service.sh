_start_service() {
  systemctl start $1
}

_stop_service() {
  systemctl stop $1
}
