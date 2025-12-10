_bootstrap() {

	[ -z "$_PLATFORM_PACKAGES" ] && return 1
	[ -n "$_BOOTSTRAP_PLATFORM_PACKAGES_INSTALLED" ] && return 2

	_INFO "Installing pre-requisites"

	_setup_run_do_bootstrap PACKAGE
	_PACKAGE_INSTALL $_PLATFORM_PACKAGES && _BOOTSTRAP_PLATFORM_PACKAGES_INSTALLED=1

}

_bootstrap_install() {
	[ -e $_APPLICATION_METADATA_PATH ] && return

	_DETAIL "Bootstrapping install"

	_PACKAGE_BOOTSTRAP
	_PACKAGE_INSTALL $_PLATFORM_PACKAGES
}
