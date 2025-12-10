lib git/data.app.sh
lib io/file.sh

cfg git

_console_conf() {
	_require_file $_HOME "_console_conf:_HOME"

	local opwd=$PWD
	cd $_CONF_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME

	find $(dirname $(dirname $0))/files/$_TARGET_APPLICATION_NAME/$_SHELL -type f -exec $_SUDO_CMD cp {} $_HOME \; || _WARN "console conf: $PWD -> $(ls)"

	[ -z "$_USER" ] && _USER=$(whoami)

	__console_set_shell
	_console_init_git_data

	cd $opwd
}

_console_init_git_data() {
	_INFO "  init git data: $_HOME : $_USER"

	_include $_TARGET_APPLICATION_NAME install git

	_PROJECT_PATH=$_HOME/.data/$_TARGET_APPLICATION_NAME
	_PROJECT=data/$(head -1 /usr/local/etc/walterjwhite/system 2>/dev/null)/$_USER/$_TARGET_APPLICATION_NAME

	_git_init
	_console_fix_permissions
}

_console_fix_permissions() {
	[ "$_USER" = "root" ] && return 1

	local chown_args="$_USER:$_USER"
	if [ $_PLATFORM = "Apple" ]; then
		chown_args="$_USER"
	fi

	_sudo chown -R $chown_args $_PROJECT_PATH
}

__console_set_shell() {
	command -v chsh >/dev/null 2>&1 || {
		_WARN "unable to set shell, chsh does not exist"
		return 1
	}

	local shell_path=$(command -v $_SHELL)
	[ $? -gt 0 ] && {
		_WARN "unable to set shell, shell [$_SHELL] does not exist"
		return 2
	}

	_sudo chsh -s $shell_path $_USER
}
