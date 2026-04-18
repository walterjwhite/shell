package_pacman_install_do() {
  pacman_flags="-Sqyu --noconfirm --noprogressbar"
  _pacman_cmd "$@"
  unset pacman_flags
}

package_pacman_uninstall_do() {
  pacman_flags="-Rq --noconfirm --noprogressbar"
  _pacman_cmd "$@"
  unset pacman_flags
}

package_pacman_is_installed() {
  pacman_flags="-Q"
  _pacman_cmd "$@"
  unset pacman_flags
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

  [ "$APP_PLATFORM_ROOT" = "/" ] && {
    pacman $pacman_flags "$@"
    return
  }

  [ "$_container_type" = "incus" ] && {
    log_warn "detected incus container, using incus exec"
    incus exec $_container_name -- pacman $pacman_flags "$@"
    return
  }

  pacman $pacman_flags --sysroot $APP_PLATFORM_ROOT "$@"
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







