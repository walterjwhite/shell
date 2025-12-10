_PACKAGE_USE_BOOTSTRAP() {
	:
}

_PACKAGE_USE_INSTALL() {
	_gentoo_portage_install_file package.use $1
}

_PACKAGE_USE_UNINSTALL() {
	_gentoo_portage_uninstall_file package.use $1
}

_PACKAGE_USE_IS_INSTALLED() {
	_gentoo_portage_is_installed package.use $1
}

_PACKAGE_USE_ENABLED() {
	return 0
}

_PACKAGE_USE_IS_FILE() {
	return 0
}
