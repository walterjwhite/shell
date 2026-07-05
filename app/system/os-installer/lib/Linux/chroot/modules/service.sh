patch_service() {
  _module_find_callback _service_do
}

_service_do() {
  local service_line
  $GNU_GREP -Pvh '^($|#)' "$1" | while read service_line; do
    [ -z "$service_line" ] && {
      log_warn "service_line was empty"
      continue
    }

    systemctl enable $service_line
  done
}
