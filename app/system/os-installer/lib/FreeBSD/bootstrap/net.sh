_init_net() {
  [ -z "$os_installer_is_install_media" ] && {
    log_warn "running on live system, no need to setup networking"
    return
  }

  _determine_network_interface

  ifconfig $_os_installer_net_dev up

  killall dhclient 2>/dev/null

  dhclient $_os_installer_net_dev >/dev/null 2>&1 || exit_with_error "unable to bring up $_os_installer_net_dev"

  mkdir -p /tmp/bsdinstall_etc
  resolvconf -u

  [ -z "$os_installer_cache" ] && return

  ssh-keygen -R $os_installer_cache
}

_determine_network_interface() {
  [ -n "$_os_installer_net_dev" ] && return

  local _os_installer_net_dev=$(ifconfig -l | tr ' ' '\n' | grep -v ^lo | grep -v ^pf | sort -u | head -1)
}
