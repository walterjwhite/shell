_MASK_BOOTSTRAP() {
	:
}

_MASK_INSTALL() {
	_gentoo_portage_install_file package.mask $1
}

_MASK_UNINSTALL() {
	_gentoo_portage_uninstall_file package.mask $1
}

_MASK_IS_INSTALLED() {
	_gentoo_portage_is_installed package.mask $1
}

_MASK_ENABLED() {
	return 0
}

_MASK_IS_FILE() {
	return 0
}
