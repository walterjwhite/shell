_uninstall() {
	_require "$_TARGET_APPLICATION_NAME" "_TARGET_APPLICATION_NAME must be set"
	_require "$_INSTALL_LIBRARY_PATH" "_INSTALL_LIBRARY_PATH must be set"

	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME ] && return 1
	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata ] && return 1

	_uninstall_script
	_uninstall_files
	_uninstall_type

	_sudo rm -Rf $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME

	_INFO "Uninstalled $_TARGET_APPLICATION_NAME"
}

_uninstall_script() {
	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/uninstall ] && return

	for script in $(find $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/uninstall -type f); do
		_sudo $script
	done
}

_uninstall_files() {
	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files ] && return

	if [ "$_ROOT" = "/" ]; then
		_sudo rm -f $(cat $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files)
	else
		local sed_safe_root=$(_sed_safe $_ROOT)
		_sudo rm -f $(sed -e "s/^/$sed_safe_root/" $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files)
	fi

	_sudo rm -f $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files
}

_uninstall_type() {
	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type ] && return 1

	for _SETUP_TYPE_FILE in $(find $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type -type f -name '.*'); do
		_SETUP_TYPE_NAME=$(basename $_SETUP_TYPE_FILE | sed -e 's/^.//')


		_uninstall_type_do
	done
}

_uninstall_type_do() {
	_${_SETUP_TYPE_NAME}_IS_FILE && {
		_WARN=$_CONF_LOG_FEATURE_TIMEOUT_ERROR_LEVEL _${_SETUP_TYPE_NAME}_UNINSTALL $_SETUP_TYPE_FILE || {
			local error=$?
			_WARN "Error uninstalling: $_SETUP_TYPE_NAME: $_SETUP_TYPE_FILE"
			return $error
		}

		return
	}

	local packages=$($_CONF_GNU_GREP -Pv '(^$|^#)' $_SETUP_TYPE_FILE | tr '\n' ' ')
	if [ -z "$packages" ]; then
		_DEBUG "No ${_SETUP_TYPE_NAME}(s) to uninstall"
		return
	fi

	[ -n "$_INSTALL" ] && {
		local packages_to_install=$(find $_CONF_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/setup \
			-type f -name "*$_SETUP_TYPE_NAME*" \
			-exec $_CONF_GNU_GREP -Pv '(^$|^#)' {} + 2>/dev/null | tr '\n' '|')

		packages=$(printf '%s' "$packages" | $_CONF_GNU_GREP -Pv "($packages_to_install)")
		[ -z "$packages" ] && {
			_WARN "uninstall - $_SETUP_TYPE_NAME - skipping"
			return 1
		}
	}

	_INFO "Uninstalling $packages via ${_SETUP_TYPE_NAME}"
	_WARN=$_CONF_LOG_FEATURE_TIMEOUT_ERROR_LEVEL _${_SETUP_TYPE_NAME}_UNINSTALL $packages || {
		local error=$?
		_WARN "Error uninstalling $packages"
		return $error
	}
}
