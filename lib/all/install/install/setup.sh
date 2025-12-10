_setup() {
	[ "$_TARGET_APPLICATION_NAME" != "install" ] && [ "$_TARGET_APPLICATION_NAME" != "git" ] && _include $_TARGET_APPLICATION_NAME

	[ -e $_CONF_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$1 ] && _setup_run $1

	return 1
}

_setup_run() {
	local setup_script
	for setup_script in $(find $_CONF_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$1 -type f 2>/dev/null | sort -u); do
		_setup_run_script "$setup_script"
	done
}

_setup_run_script() {
	_SETUP_TYPE_NAME=$(basename $1)

	_setup_contains_subtype $_SETUP_TYPE_NAME && {
		_setup_sub_platform_matches $_SETUP_TYPE_NAME || {
			_WARN "Ignoring $1, does not target this sub-platform"
			return
		}
	}

	case $_SETUP_TYPE_NAME in
	*.*)
		_SETUP_TYPE_NAME=$(printf '%s' $_SETUP_TYPE_NAME | sed -e "s/^.*\.//")
		;;
	esac

	_SETUP_TYPE_NAME=${_SETUP_TYPE_NAME%_*}
	_SETUP_TYPE_NAME=$(printf '%s' $_SETUP_TYPE_NAME | tr '[:lower:]' '[:upper:]')

	type _${_SETUP_TYPE_NAME}_BOOTSTRAP >/dev/null 2>&1 || {
		_WARN "Unknown type: $_SETUP_TYPE_NAME"
		return
	}

	if [ ! -e $1 ]; then
		_WARN "$1 no longer exists, ignoring"
		return 0
	fi

	_variable_is_set _${_SETUP_TYPE_NAME}_DISABLED && return

	_sudo mkdir -p "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type"

	_setup_run_do_bootstrap $_SETUP_TYPE_NAME
	_${_SETUP_TYPE_NAME}_IS_FILE
	if [ $? -eq 0 ]; then
		_WARN=$_CONF_LOG_FEATURE_TIMEOUT_ERROR_LEVEL _${_SETUP_TYPE_NAME}_INSTALL $1 || {
			local error=$?
			_WARN "Error installing: $_SETUP_TYPE_NAME: $1"
			return $error
		}

		_call _${_SETUP_TYPE_NAME}_GET_DATA $1 | _append "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type/${_SETUP_TYPE_NAME}"
	else
		local packages=$($_CONF_GNU_GREP -Pv '(^$|^#)' $1 | tr '\n' ' ')

		_WARN=$_CONF_LOG_FEATURE_TIMEOUT_ERROR_LEVEL _${_SETUP_TYPE_NAME}_INSTALL $packages || {
			local error=$?
			_WARN "Error installing $packages"
			return $error
		}

		printf "$packages" | tr ' ' '\n' | _append "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type/${_SETUP_TYPE_NAME}"
	fi

	_call _${_SETUP_TYPE_NAME}_CLEANUP

	return 0
}

_setup_contains_subtype() {
	[ -z "$_SUB_PLATFORM" ] && return 1

	case $1 in
	*_*)
		return 0
		;;
	esac

	return 1
}

_setup_sub_platform_matches() {
	local setup_type_sub_platform=${1##*_}

	setup_type_sub_platform=${setup_type_sub_platform%%.*}

	[ -z "$setup_type_sub_platform" ] && return 0

	[ "$setup_type_sub_platform" = "$_SUB_PLATFORM" ] && return 0

	return 1
}

_setup_run_do_bootstrap() {
	_setup_type_bootstrapped $1 || {
		_call _${1}_BOOTSTRAP
		_call _${1}_BOOTSTRAP_POST

		printf '_BOOTSTRAP_%s=1\n' "$1" | _install_metadata_append
	}
}

_setup_type_bootstrapped() {
	_install_metadata_is_set "_BOOTSTRAP_${1}=1"
}

_setup_type_is_installed() {
	find $_CONF_LIBRARY_PATH -type f -path "*/type/$_SETUP_TYPE_NAME" -exec $_CONF_GNU_GREP -Pqm1 "^$1$" {} +
}
