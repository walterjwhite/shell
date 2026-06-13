package_pacman_requires_reboot() {
  local datestamp=$(date +%Y-%m-%d)
  $GNU_GREP -Pcqm1 \
    "\[${datestamp}T[\d]{2}:[\\d]{2}:[\\d]{2}-[\\d]{4}\] \[ALPM\] upgraded ($conf_system_maintenance_reboot_packages)" \
    /var/log/pacman.log
}

package_pacman_install_do() {
  pacman_flags="-Sqyu --noconfirm --noprogressbar"
  _pacman_cmd "$@"
  local status=$?
  unset pacman_flags

  return $status
}

package_pacman_uninstall_do() {
  pacman_flags="-Rs --noconfirm --noprogressbar"
  _pacman_cmd "$@"
  local status=$?
  unset pacman_flags

  return $status
}

package_pacman_is_installed() {
  pacman_flags="-Q"
  _pacman_cmd "$@"
  local status=$?
  unset pacman_flags

  return $status
}

package_pacman_bootstrap() {
  _pacman_setup_keys
}

package_pacman_update() {
  pacman_flags="-Syuq --noconfirm --noprogressbar"
  _pacman_cmd "$@"
  unset pacman_flags

  aur_package_update
}

_pacman_cmd() {
  local log_target=/dev/null
  [ -n "$log_logfile" ] && log_target=$log_logfile

  [ "$APP_PLATFORM_ROOT" = "/" ] && {
    pacman $pacman_flags "$@" >$log_target 2>&1
    return
  }

  [ "$_container_type" = "incus" ] && {
    log_warn "detected incus container, using incus exec"
    incus exec $_container_name -- pacman $pacman_flags "$@" >$log_target 2>&1
    return
  }

  pacman $pacman_flags --sysroot $APP_PLATFORM_ROOT "$@" >$log_target 2>&1
}

_pacman_setup_keys() {
  [ -e $APP_PLATFORM_ROOT/etc/pacman.d/gnupg ] && {
    log_debug "pacman keys already initialized"
    return
  }

  mkdir -p $APP_PLATFORM_ROOT/etc/pacman.d/gnupg
  pacman-key --init
  pacman-key --populate archlinux cachyos
}

pacman_package_bootstrap_is_package_available() {
  return 0
}







