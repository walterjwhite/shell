pypi_bootstrap() {
  _pypi_bootstrap_is_pypi_available || {
    _package_install_new_only $PYPI_PACKAGE
    _pypi_bootstrap_is_pypi_available || pypi_disabled=1
  }
}

_pypi_bootstrap_is_pypi_available() {
  command -v pip >/dev/null 2>&1
}

_pypi_install_do() {
  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    sudo_run pip install -U --no-input "$1" >/dev/null
  else
    pip install -U --no-input --user "$1" >/dev/null
  fi
}

_pypi_uninstall_do() {
  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    sudo_run pip uninstall -y "$1" >/dev/null
  else
    pip uninstall -y "$1" >/dev/null
  fi
}
