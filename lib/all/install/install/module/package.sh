_PACKAGE_BOOTSTRAP() {
	:
}

_PACKAGE_INSTALL() {
	[ $# -eq 0 ] && {
		_WARN "no packages to install, none specified"
		return 1
	}

	local packages
	local package
	for package in "$@"; do
		_PACKAGE_IS_INSTALLED $package || {
			if [ -n "$packages" ]; then
				packages="$packages $package"
			else
				packages="$package"
			fi
		}
	done

	if [ -n "$packages" ]; then
		_PACKAGE_INSTALL_DO "$packages"
	else
		_WARN "Packages [$*] are already installed, skipping"
		return 0
	fi
}

_PACKAGE_IS_FILE() {
	return 1
}

_PACKAGE_ENABLED() {
	return 0
}
