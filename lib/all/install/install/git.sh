_clone() {
	_INFO "Git Clone: $_TARGET_APPLICATION_NAME"

	_do_clone $_CONF_APP_REGISTRY_GIT_URL $_CONF_DATA_REGISTRY_PATH && {
		_app_dir_setup

		_TARGET_APPLICATION_VERSION=$(grep _APPLICATION_VERSION= .app | cut -f2 -d=)
		_app_dir_exists
		return
	}

	_ERROR "Unable to clone: $_TARGET_APPLICATION_NAME in any of $_CONF_APP_REGISTRY_GIT_URL"
}

_git_does_repository_exist() {
	case $1 in
	http*)
		local http_status_code=$(curl -Is $1 2>/dev/null | head -n 1 | cut -d$' ' -f2)
		if [ $http_status_code -lt 400 ]; then
			return 0
		fi
		;;
	*:*)
		git ls-remote $1 >/dev/null 2>&1 && return 0
		;;
	*)
		if [ -e $1 ]; then
			return 0
		fi
		;;
	esac

	return 1
}

_app_dir_setup() {
	cd $_CONF_DATA_REGISTRY_PATH

	[ ! -e $_TARGET_APPLICATION_NAME ] && _ERROR "$_TARGET_APPLICATION_NAME does not exist in the registry"

	cd $_TARGET_APPLICATION_NAME
}

_app_dir_exists() {
	_DETAIL "Cloned registry and $_TARGET_APPLICATION_NAME exists @ $_TARGET_APPLICATION_VERSION"
}

_require_ssh_keys() {
	if [ $(find ~/.ssh -maxdepth 1 -type f -name '*.pub' | wc -l) -eq 0 ]; then
		_ERROR "SSH public key is required"
	fi
}
