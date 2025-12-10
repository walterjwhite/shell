_PYPI_BOOTSTRAP() {
	_PYPI_BOOTSTRAP_IS_PYPI_AVAILABLE || {
		_PACKAGE_INSTALL $PYPI_PACKAGE
		_PYPI_BOOTSTRAP_IS_PYPI_AVAILABLE || PYPI_DISABLED=1
	}
}

_PYPI_BOOTSTRAP_IS_PYPI_AVAILABLE() {
	which pip >/dev/null 2>&1
}

_PYPI_INSTALL() {
	_sudo pip install -U --no-input "$@" >/dev/null
}

_PYPI_UNINSTALL() {
	_sudo pip uninstall -y "$@" >/dev/null
}

_PYPI_IS_INSTALLED() {
	_setup_type_is_installed "$1"
}

_PYPI_IS_FILE() {
	return 1
}
