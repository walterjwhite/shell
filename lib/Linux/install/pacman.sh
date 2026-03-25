package_pacman_install_do() {
  flags="-Sqyu --noconfirm"
  _pacman_cmd "$@"
}

package_pacman_uninstall_do() {
  flags="-Rq --noconfirm"
  _pacman_cmd "$@"
}

package_pacman_is_installed() {
  flags="-Q"
  _pacman_cmd "$@"
}

package_pacman_bootstrap() {
  _pacman_setup_keys
}

package_pacman_update() {
  flags="-Syuq --noconfirm"
  _pacman_cmd "$@"

  aur_package_update
}

_pacman_cmd() {

  [ "$APP_PLATFORM_ROOT" = "/" ] && {
    pacman $flags "$@" 2>&1 >/dev/null
    return
  }

  [ "$_container_type" = "incus" ] && {
    log_warn "detected incus container, using incus exec"
    incus exec $_container_name -- pacman $flags "$@" 2>&1 >/dev/null
    return
  }

  pacman $flags --sysroot $APP_PLATFORM_ROOT "$@" 2>&1 >/dev/null
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







