pypi_bootstrap() {
  _pypi_bootstrap_is_pypi_available || {
    _package_install_new_only $PYPI_PACKAGE
    _pypi_bootstrap_is_pypi_available || pypi_disabled=1
  }
}

_pypi_bootstrap_is_pypi_available() {
  which pip >/dev/null 2>&1
}

_pypi_install_do() {
  pip install -U --no-input "$1" >/dev/null
}

_pypi_uninstall_do() {
  pip uninstall -y "$1" >/dev/null
}
