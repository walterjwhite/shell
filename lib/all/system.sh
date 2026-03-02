system_get_id() {
  system_id=$(head -1 $PLATFORM_SYSTEM_ID_PATH 2>/dev/null)
}

system_write_id() {
  _write_write $PLATFORM_SYSTEM_ID_PATH
}
