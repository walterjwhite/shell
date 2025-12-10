_settings_init() {
	if [ -z "$_ROOT" ]; then
		_ROOT=/
	fi

	_ROOT=$(_readlink $_ROOT)
	_INFO "Using root directory: $_ROOT"

	_INSTALL_BIN_PATH=$(_SUDO_REQUIRED=1 _readlink $_ROOT/$_CONF_BIN_PATH)
	_INSTALL_CONFIG_PATH=$(_SUDO_REQUIRED=1 _readlink $_ROOT/$_CONF_CONFIG_PATH)
	_INSTALL_DATA_PATH=$(_SUDO_REQUIRED=1 _readlink $_ROOT/$_CONF_DATA_PATH)
	_INSTALL_LIBRARY_PATH=$(_SUDO_REQUIRED=1 _readlink $_ROOT/$_CONF_LIBRARY_PATH)

	_APPLICATION_METADATA_PATH=$_INSTALL_LIBRARY_PATH/install/.metadata

	_include $_APPLICATION_METADATA_PATH

	if [ "$_ROOT" != "/" ]; then
		unset $(env | tr '\0' '\n' | $_CONF_GNU_GREP -P '^_BOOTSTRAP_[A-Z0-9_]+=' | sed -e 's/=.*$//' | tr '\n' ' ')
	fi
}

_application_settings() {


	_TARGET_APPLICATION_BUILD_DATE=$(git log --format=%cd -1)

	_TARGET_APPLICATION_INSTALL_DATE=$(date +"%a %b %d %H:%M:%S %Y %z")

	_TARGET_APPLICATION_DATA_PATH=$_INSTALL_DATA_PATH/$_TARGET_APPLICATION_NAME
	_TARGET_APPLICATION_CONFIG_PATH="$_INSTALL_CONFIG_PATH/$_TARGET_APPLICATION_NAME"
	_TARGET_APPLICATION_METADATA_PATH=$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata

	_TARGET_APPLICATION_GIT_URL=$(git remote -v | awk {'print$2'} | head -1)

	mkdir -p $_INSTALL_DATA_PATH/install $_CONF_DATA_PATH $_TARGET_APPLICATION_DATA_PATH

	_include $_TARGET_APPLICATION_CONFIG_PATH
}

_application_defaults() {
	local default_file
	for default_file in $(find $1/cfg -type f 2>/dev/null); do
		_include $default_file
	done
}
