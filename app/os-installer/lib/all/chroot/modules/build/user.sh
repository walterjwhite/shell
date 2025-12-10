lib install/install/module/user.sh

_PATCH_USER() {
	_user_bootstrap

	local user_conf
	for user_conf in $@; do
		_BACKUP_SSH=1 _users_add $user_conf

		unset _CONFIGURATION_INSTALLED _BACKUP_SSH
	done
}
