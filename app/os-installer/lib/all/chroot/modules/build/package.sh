lib install/install

_PACKAGE_IS_FILE=1
_PATCH_PACKAGE() {
	[ $# -eq 0 ] && _ERROR 'No packages'

	[ "$_CONF_OS_INSTALLER_PACKAGE_INSTALL_ONCE" -eq "0" ] && {
		_PACKAGE_INSTALL "$@"
		return
	}

	local package
	for package in "$@"; do
		_PACKAGE_INSTALL $package
	done
}
