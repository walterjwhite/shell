_cleanup_processes() {
  local jid
  for jid in $(jls | sed 1d | grep "$os_installer_jail_prefix" | awk {'print$1'}); do
    log_info "removing jail $jid"
    jail -r $jid
  done
}
