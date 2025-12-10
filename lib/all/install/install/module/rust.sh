_RUST_BOOTSTRAP() {
	_RUST_BOOTSTRAP_IS_RUST_AVAILABLE || {
		_PACKAGE_INSTALL $RUST_PACKAGE
		_RUST_BOOTSTRAP_IS_RUST_AVAILABLE || RUST_DISABLED=1
	}
}

_RUST_BOOTSTRAP_IS_RUST_AVAILABLE() {
	which cargo >/dev/null 2>&1
}

_RUST_INSTALL() {
	local rust_root_dir=$(printf '%s' $_INSTALL_BIN_PATH | sed 's/\/bin//')
	_sudo cargo install --root=$rust_root_dir "$@"
}

_RUST_UPDATE() {
	_sudo cargo update "$@"
}

_RUST_UNINSTALL() {
	_sudo cargo uninstall "$@"
}

_RUST_IS_INSTALLED() {
	_setup_type_is_installed "$1"
}

_RUST_IS_FILE() {
	return 1
}
