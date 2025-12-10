_configure() {
	_INFO "configuring system"
	cd $OS_INSTALLER_SYSTEM_WORKSPACE

	_configure_system
	_configure_patches
}

_configure_system() {
	_INFO "configuring system/conf"
	[ -e system/conf ] && {
		_INFO "importing system/conf"
		. system/conf
	}

	local import_file
	for import_file in $(find imports -type f -path '*/system/conf'); do
		_INFO "importing $import_file"
		. $import_file
	done
}

_configure_patches() {
	_INFO "configuring patches - $PWD"

	local configuration_script patch_path
	for configuration_script in $(find . -type f -path '*.patch/configure'); do
		patch_path=$(dirname $configuration_script)

		_DETAIL "evaluating $patch_path"

		$configuration_script || {
			_WARN "$configuration_script [$?], disabling patch"
			rm -rf $patch_path

			continue
		}

		_DETAIL "Keeping $patch_path"
	done
}
