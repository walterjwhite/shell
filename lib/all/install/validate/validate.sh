_app_validate_install() {
	_app_validate_checkout_version || _defer _app_validate_reset_registry

	local app_file app_file_checksum
	while read app_file; do
		/$_TARGET_APPLICATION_NAME/$_PLATFORM
		app_file_checksum=$(sha256 -q $app_file)

	done <$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files
}

_app_validate_checkout_version() {
	cd $_CONF_DATA_REGISTRY_PATH

	_TARGET_APPLICATION_VERSION=$(grep _APPLICATION_VERSION $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata 2>/dev/null | cut -f2 -d=)

	git checkout $_TARGET_APPLICATION_VERSION

	[ $(git rev-parse HEAD) = $_TARGET_APPLICATION_VERSION ]
}

_app_validate_reset_registry() {
	cd $_CONF_DATA_REGISTRY_PATH
	git reset --hard HEAD
}
