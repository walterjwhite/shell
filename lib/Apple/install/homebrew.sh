
package_bootstrap() {
  if [ ! -e "$homebrew_conf_install_homebrew_cmd" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    grep -qm1 homebrew ~/.zprofile || printf 'eval "$(%s shellenv)"\n' "$homebrew_conf_install_homebrew_cmd" >>~/.zprofile
    eval "$($homebrew_conf_install_homebrew_cmd shellenv)"

    return
  fi

  log_warn "homebrew appears to already be installed"
}

_package_install_do() {
  brew install "$@"
}

_package_uninstall_do() {
  brew uninstall "$@"
}

package_bootstrap_uninstall() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

  rm -rf /opt/homebrew
}

package_update() {
  brew update
  brew upgrade "$@"
}

_package_is_installed() {
  local _package=$1
  brew ls --versions "$_package" >/dev/null
  if [ $? -gt 0 ]; then
    return 1
  fi

  brew outdated "$_package" >/dev/null
}

