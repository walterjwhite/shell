_setup_project() {
	case $_TARGET_APPLICATION_NAME in
	*.zip:*)
		_install_app_registry_from_zip
		;;
	*)
		_clone
		;;
	esac

	_is_latest $_TARGET_APPLICATION_NAME && {
		[ -z "$_INSTALL_FORCE" ] && {
			_WARN "Latest version of app is already installed: $_TARGET_APPLICATION_NAME [$_LATEST_APPLICATION_VERSION]"
			return 1
		}
	}

	_is_app

	_TARGET_PLATFORM=$_PLATFORM

	[ ! -e $_TARGET_PLATFORM ] && _ERROR "No artifacts exist for $_TARGET_PLATFORM"

	_application_settings
	_application_defaults $_TARGET_PLATFORM


	[ $_OPTN_INSTALL_BYPASS_UNINSTALL ] || _INSTALL=1 _uninstall
	_prepare_target
	_bootstrap

	_metadata_write_app

	_install $_TARGET_PLATFORM

	_setup setup

	[ -e $_TARGET_PLATFORM/feature ] && _features $_TARGET_PLATFORM/feature

	_setup post-setup

	_INFO "$_TARGET_APPLICATION_NAME - Completed installation"
}
