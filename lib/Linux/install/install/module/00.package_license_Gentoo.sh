_PACKAGE_LICENSE_BOOTSTRAP() {
	:
}

_PACKAGE_LICENSE_INSTALL() {
	_gentoo_portage_install_file package.license $1
}

_PACKAGE_LICENSE_UNINSTALL() {
	_gentoo_portage_uninstall_file package.license $1
}

_PACKAGE_LICENSE_IS_INSTALLED() {
	_gentoo_portage_is_installed package.license $1
}

_PACKAGE_LICENSE_ENABLED() {
	return 0
}

_PACKAGE_LICENSE_IS_FILE() {
	return 0
}
