package_pacman_install_do() {
  _pacman_cmd -Sqyu --noconfirm "$@"
}

package_pacman_uninstall_do() {
  _pacman_cmd -Rq --noconfirm "$@"
}

package_pacman_is_installed() {
  _pacman_cmd -Q "$@" 
}

package_pacman_bootstrap() {
  _pacman_setup_keys
}

package_pacman_update() {
  _pacman_cmd -Syuq --noconfirm "$@"
}

_pacman_cmd() {
  [ "$APP_PLATFORM_ROOT" = "/" ] && {
    pacman "$@"
    return
  }

  [ "$_container_type" = "incus" ] && {
    log_warn "detected incus container, using incus exec"
    incus exec $_container_name -- pacman "$@"
    return
  }

  pacman --sysroot $APP_PLATFORM_ROOT "$@"
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
