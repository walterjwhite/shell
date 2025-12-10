lib extract.sh

_install_app_registry_from_zip() {
	_DETAIL "Installing from app.registry zip: $_TARGET_APPLICATION_NAME"

	[ -z "$_APP_REGISTRY_ZIP_EXTRACTED" ] && {
		rm -rf $_CONF_DATA_REGISTRY_PATH && mkdir -p $_CONF_DATA_REGISTRY_PATH

		local temp_dir=$(_MKTEMP_OPTIONS=d _mktemp)
		local zip_file="${_TARGET_APPLICATION_NAME%%:*}"
		_extract $zip_file $temp_dir || _ERROR "Error extracting zip"

		cd $temp_dir
		cd $(ls -1 | head -1)

		mv * $_CONF_DATA_REGISTRY_PATH
		_APP_REGISTRY_ZIP_EXTRACTED=1

		cd $_CONF_DATA_REGISTRY_PATH
		rm -rf $temp_dir
	}

	_TARGET_APPLICATION_NAME=${_TARGET_APPLICATION_NAME#*:}

	_app_dir_setup

	_TARGET_APPLICATION_VERSION=$(_install_app_registry_checksum)
	_app_dir_exists
}

_install_app_registry_checksum() {
	for f in $(find . -type f | sort -u); do
		sha256sum $f | awk {'print$1'}
	done | sha256sum | awk {'print$1'}
}
