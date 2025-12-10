lib ssh.sh

_user_bootstrap() {
	_sudo mkdir -p /root/.ssh/socket
	_sudo chmod -R 700 /root/.ssh/socket

	_PRESERVE_LOG=1 _CHILD=1 _sudo app-install configuration
}

_user_install() {
	_users_add "$1"
}

_USER_UNINSTALL() {
	. "$1"

	_require "$username" "username"
	_sudo userdel $username
}

_user_is_installed() {
	:
}

_user_enabled() {
	return 0
}

_users_add_argument() {
	[ -n "$2" ] && user_options="$user_options $1 $2"
}

_users_add() {
	. $1

	if [ "$username" != "root" ]; then
		_sudo pw user show $username >/dev/null 2>&1 || {
			_INFO "### Add User: $1: $username"

			user_options="-m"

			_users_add_argument "-g" "$gid"
			_users_add_argument "-G" "$grouplist"
			_users_add_argument "-s" "$shell"
			_users_add_argument "-u" "$uid"
			_users_add_argument "-p" "$password"

			_sudo useradd $user_options $username
		}
	else
		[ -n "$shell" ] && {
			_INFO "# Setting shell to $shell for root"
			_sudo chsh -s "$shell"
		}

		if [ -n "$password" ]; then
			_INFO "# Setting root password"
			_sudo usermod -p "$password" $username
		fi
	fi

	_users_configure
	_users_cleanup
}

_users_get_data() {
	printf '%s\n' "$username" | tr ' ' '\n'
}

_users_cleanup() {
	unset user_options username gid grouplist shell uid password system
}

_users_configure() {
	local user_home=$(grep "^$username:" /etc/passwd | cut -f6 -d':')

	_prepare_ssh_conf $user_home $username

	local original_pwd=$PWD
	cd /tmp

	if [ -n "$system" ]; then
		_WARN "$username is a system user, bypassing configuration"
	else
		_WARN_ON_ERROR=1 _CHILD=1 _PRESERVE_LOG=1 _SUDO_USER=$username \
			sudo_options="--preserve-env=_CHILD,_PRESERVE_LOG,_CONF_GIT_MIRROR_LOG_TARGET,http_proxy,https_proxy,_SUDO_USER,_WARN_ON_ERROR -H" \
			_ _sudo conf restore || _user_configure_debug
	fi

	[ "$username" != "root" ] && {
		_sudo chown -R $username:$username $user_home
	}

	cd $original_pwd
}

_user_configure_debug() {
	_WARN "Error restoring configuration for $username"
	cat $user_home/.ssh/id_*.pub
	cat $user_home/.ssh/authorized_keys
	cat $user_home/.ssh/config
}
