npm_bootstrap() {
  _npm_bootstrap_is_npm_available || {
    _npm_bootstrap_pre
    _package_install_new_only $NPM_PACKAGE
    _npm_bootstrap_is_npm_available || npm_disabled=1
  }

  _npm_setup_proxy
}

_npm_bootstrap_pre() {
  :
}

_npm_bootstrap_is_npm_available() {
  which npm >/dev/null 2>&1
}

_npm_install_do() {
  _npm_is_installed $1 && {
    log_detail "$1 is already installed"
    return 0
  }

  npm install -s -g "$1"
}

_npm_uninstall_do() {
  npm uninstall -s -g "$1"
}

_npm_is_installed() {
  npm_bootstrap

  npm list -g $1 >/dev/null
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
