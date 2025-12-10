lib install/install

_PACKAGE_UNINSTALL_IS_FILE=1
_PATCH_PACKAGE_UNINSTALL() {
	[ $# -eq 0 ] && _ERROR 'No packages'

	_PACKAGE_UNINSTALL "$@"
}
