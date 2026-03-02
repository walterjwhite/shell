patch_cups_printer() {
  _module_find_callback _cups_printer_add
}

_cups_printer_add() {
  _cups_printer_exists $1 && return

  log_info "adding $1"
  cat $1 >>$conf_os_installer_cups_conf_dir/printers.conf
}

_cups_printer_exists() {
  [ ! -e $conf_os_installer_cups_conf_dir/printers.conf ] && return 1

  local printer_uuid=$(grep ^UUID $1 | sed -e 's/UUID urn:uuid://')
  [ $(grep -c $printer_uuid $conf_os_installer_cups_conf_dir/printers.conf) -eq 0 ] && return 1

  log_warn "printer ($printer_uuid) already exists"
  return 0
}
