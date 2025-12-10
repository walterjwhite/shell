_PACKAGE_ACCEPT_KEYWORDS_BOOTSTRAP() {
	:
}

_PACKAGE_ACCEPT_KEYWORDS_INSTALL() {
	_gentoo_portage_install_file package.accept_keywords $1
}

_PACKAGE_ACCEPT_KEYWORDS_UNINSTALL() {
	_gentoo_portage_uninstall_file package.accept_keywords $1
}

_PACKAGE_ACCEPT_KEYWORDS_IS_INSTALLED() {
	_gentoo_portage_is_installed package.accept_keywords $1
}

_PACKAGE_ACCEPT_KEYWORDS_ENABLED() {
	return 0
}

_PACKAGE_ACCEPT_KEYWORDS_IS_FILE() {
	return 0
}
