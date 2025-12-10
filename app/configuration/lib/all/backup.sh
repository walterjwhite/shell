_CONFIGURE_BACKUP() {
	_TAR_CD='-C'
	[ -d "$_PLUGIN_CONFIGURATION_PATH" ] && {
		[ -z "$_PLUGIN_INCLUDE" ] && {
			_PLUGIN_INCLUDE='.'
		}

		return
	}

	[ ! -e "$_PLUGIN_CONFIGURATION_PATH" ] && {
		_WARN "$_PLUGIN_CONFIGURATION_PATH does not exist"
		return 1
	}

	local plugin_configuration_dir=$(dirname "$_PLUGIN_CONFIGURATION_PATH")
	_TAR_CD="-C $plugin_configuration_dir"

	_PLUGIN_CONFIGURATION_PATH=$(basename "$_PLUGIN_CONFIGURATION_PATH")
}

_CONFIGURE_BACKUP_POST() {
	git add "$_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME"
}

_CONFIGURE_BACKUP_PREPARE() {
	rm -rf "$_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME"
	mkdir -p "$_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME"
}

_CONFIGURE_BACKUP_DEFAULT() {
	local tar_exclude=""
	if [ -n "$_PLUGIN_EXCLUDE" ]; then
		tar_exclude=$(printf '%s' "$_PLUGIN_EXCLUDE" | sed -e 's/ / --exclude /g' -e 's/^/--exclude /')
	fi

	tar -cp $_TAR_ARGS $_TAR_CD "$_PLUGIN_CONFIGURATION_PATH" $tar_exclude $_PLUGIN_INCLUDE 2>/dev/null | tar -xp $_TAR_ARGS -C "$_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME"
	unset _TAR_CD
}

_CONFIGURE_BACKUP_SYNC() {
	git status >/dev/null 2>&1 || {
		_WARN "Git Configuration repository not setup for $USER"
		return 1
	}

	if [ $(git remote -v | wc -l) -eq 0 ]; then
		_WARN "No remotes setup"
		return 1
	fi

	gd && _continue_if "Continue synchronizing contents?" "Y/n" && {
		gcommit -am 'sync'
		gpush
	}
}
