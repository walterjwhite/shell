lib crontab.sh

cfg cron

_CRONTAB_BOOTSTRAP() {
	:
}

_CRONTAB_INSTALL() {
	local osudo_user=$_SUDO_USER
	_SUDO_USER=root

	_CRONTAB_UNINSTALL

	local temp_crontab=$(_mktemp)

	_sudo cp $1 $temp_crontab

	_sudo $_CONF_GNU_SED -i "s/$/ # app.$_TARGET_APPLICATION_NAME/" $temp_crontab
	printf '\n' | _sudo tee -a $temp_crontab >/dev/null 2>&1

	_sudo $_CONF_GNU_SED -i "1i # app.$_TARGET_APPLICATION_NAME" $temp_crontab
	_sudo $_CONF_GNU_SED -i "1i \\" $temp_crontab

	_crontab_append $_SUDO_USER $temp_crontab
	_sudo rm -f $temp_crontab

	_SUDO_USER=$osudo_user
}

_CRONTAB_UNINSTALL() {
	local osudo_user=$_SUDO_USER
	_SUDO_USER=root

	local temp_crontab=$(_mktemp)

	_CRONTAB_REMOVE $temp_crontab

	_crontab_write $_SUDO_USER $temp_crontab
	_sudo rm -f $temp_crontab

	_SUDO_USER=$osudo_user
}

_CRONTAB_REMOVE() {
	_crontab_get $_SUDO_USER $1

	_sudo $_CONF_GNU_SED -i '/^$/d' $1

	_sudo $_CONF_GNU_SED -i "/# app.$_TARGET_APPLICATION_NAME/d" $1
}

_CRONTAB_IS_INSTALLED() {
	local osudo_user=$_SUDO_USER
	_SUDO_USER=root

	local temp_crontab=$(_mktemp)

	_crontab_get $_SUDO_USER $temp_crontab

	_sudo grep -qm1 "# app.$_TARGET_APPLICATION_NAME" $temp_crontab
	_sudo rm -f $temp_crontab

	_SUDO_USER=$osudo_user
}

_CRONTAB_ENABLED() {
	return 0
}

_CRONTAB_IS_FILE() {
	return 0
}
