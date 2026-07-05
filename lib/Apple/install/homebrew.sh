
package_bootstrap() {
  if [ ! -e "$homebrew_conf_install_homebrew_cmd" ]; then
    /bin/bash -c "$(curl $conf_curl_flags -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    grep -qm1 homebrew $HOME/.zprofile || printf 'eval "$(%s shellenv)"\n' "$homebrew_conf_install_homebrew_cmd" >>$HOME/.zprofile
    eval "$($homebrew_conf_install_homebrew_cmd shellenv)"

    return
  fi

  log_warn "homebrew appears to already be installed"
}

_package_install_do() {
  _homebrew_run install "$@"
}

_package_uninstall_do() {
  _homebrew_run uninstall "$@"
}

package_bootstrap_uninstall() {
  /bin/bash -c "$(curl $conf_curl_flags -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

  rm -rf /opt/homebrew
}

package_update() {
  log_detail 'updated packages via homebrew'
  _homebrew_run update
  _homebrew_run upgrade "$@"
}

_package_is_installed() {
  local _package=$1
  _homebrew_run ls --versions "$_package" >/dev/null
  if [ $? -gt 0 ]; then
    return 1
  fi

  _homebrew_run outdated "$_package" >/dev/null
}


_homebrew_run() {
  if [ "$(id -u)" -eq 0 ]; then
    sudo_user="${SUDO_USER:-$USER}" sudo_run brew "$@"
  else
    brew "$@"
  fi
}
