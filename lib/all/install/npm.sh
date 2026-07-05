npm_bootstrap() {
  _npm_bootstrap_is_npm_available || {
    _npm_bootstrap_pre
    _package_install_new_only $NPM_PACKAGE
    _npm_bootstrap_is_npm_available || npm_disabled=1
  }

  _npm_setup_proxy
  exec_call npm_bootstrap_platform
}

_npm_bootstrap_pre() {
  :
}

_npm_bootstrap_is_npm_available() {
  command -v npm >/dev/null 2>&1
}

_npm_prefix() {
  printf '%s' "$TARGET_APP_PLATFORM_BIN_PATH" | sed -e 's/\/bin$//'
}

_npm_install_do() {
  _npm_is_installed $1 && {
    log_detail "$1 is already installed"
    return 0
  }

  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    sudo_run npm install -s -g --prefix "$(_npm_prefix)" "$1"
  else
    npm install -s -g --prefix "$(_npm_prefix)" "$1"
  fi
}

_npm_uninstall_do() {
  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    sudo_run npm uninstall -s -g --prefix "$(_npm_prefix)" "$1"
  else
    npm uninstall -s -g --prefix "$(_npm_prefix)" "$1"
  fi
}

_npm_is_installed() {
  npm list -g --prefix "$(_npm_prefix)" "$1" >/dev/null 2>&1
}

_npm_setup_proxy() {
  [ -z "$http_proxy" ] && return

  log_warn "configuring NPM to use an HTTP proxy: $http_proxy"

  npm config set proxy $http_proxy
  npm config set https-proxy $https_proxy

  exit_defer _npm_clear_proxy
}

_npm_clear_proxy() {
  log_warn "reverting NPM HTTP proxy: $http_proxy"

  npm config rm proxy
  npm config rm https-proxy
}
