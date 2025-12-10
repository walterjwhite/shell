_NPM_BOOTSTRAP() {
	_NPM_BOOTSTRAP_IS_NPM_AVAILABLE || {
		_npm_setup_use_flags
		_PACKAGE_INSTALL $NPM_PACKAGE
		_NPM_BOOTSTRAP_IS_NPM_AVAILABLE || NPM_DISABLED=1
	}

	_NPM_SETUP_PROXY
}

_npm_setup_use_flags() {
	local use_flag_file=/tmp/install-gentoo-npm.use
	printf '%s npm\n' $NPM_PACKAGE >$use_flag_file
	_F_00_PACKAGE_USE_INSTALL $use_flag_file

	rm -f $use_flag_file
}
