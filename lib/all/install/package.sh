_package_install_new_only() {
  [ $# -eq 0 ] && return

  local package_install_packages=""
  local package
  for package in "$@"; do
    _package_is_installed $package || {
      if [ -n "$package_install_packages" ]; then
        package_install_packages="$package_install_packages $package"
      else
        package_install_packages="$package"
      fi
    }
  done

  if [ -n "$package_install_packages" ]; then
    _package_install_do $package_install_packages
  else
    log_warn "packages [$*] are already installed, skipping"
    return 0
  fi
}
