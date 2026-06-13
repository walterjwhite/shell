aur_package_install() {
  aur_package_install_new_only $(_install_filter_file $1)
}

aur_package_install_new_only() {
  [ $# -eq 0 ] && return

  local package_install_packages=""
  local package
  for package in "$@"; do
    aur_package_is_installed $package || {
      if [ -n "$package_install_packages" ]; then
        package_install_packages="$package_install_packages $package"
      else
        package_install_packages="$package"
      fi
    }
  done

  if [ -n "$package_install_packages" ]; then
    aur_package_install_do $package_install_packages
  else
    log_warn "packages [$*] are already installed, skipping"
    return 0
  fi
}

aur_package_install_do() {
  flags="-Sqyu --noconfirm"
  _aur_cmd "$@"
}

aur_package_uninstall() {
  _install_uninstall_filter_file_callback $1 aur_package_uninstall_do
}

aur_package_uninstall_do() {
  flags="-Rq --noconfirm"
  _aur_cmd "$@"
}

aur_package_is_installed() {
  flags="-Q"
  _pacman_cmd "$@"
}

aur_package_update() {
  flags="-Syuq --noconfirm"

  _aur_cmd "$@"
}

aur_package_bootstrap() {
  getent passwd builduser >/dev/null 2>&1 && return

  useradd -m builduser
  printf "builduser ALL=(ALL) NOPASSWD: ALL\n" >/etc/sudoers.d/builduser
  chmod 440 /etc/sudoers.d/builduser

  flags="-Sqyu --noconfirm"

  _pacman_cmd paru
}

_aur_cmd() {
  [ "$#" -eq 0 ] && return

  [ "$APP_PLATFORM_ROOT" = "/" ] && {
    su - builduser -c "paru $flags $@" 2>&1 >/dev/null
    return
  }

  [ "$_container_type" = "incus" ] && {
    log_warn "detected incus container, using incus exec"
    incus exec $_container_name -- su - builduser -c "paru $flags $@" 2>&1 >/dev/null
    return
  }

  su - builduser -c "paru $flags --sysroot $APP_PLATFORM_ROOT $@" 2>&1 >/dev/null
}
