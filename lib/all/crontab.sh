lib io/file.sh

_crontab_clear() {
	_require "$1" "Crontab User"
	_CRONTAB_${_CONF_CRON_PROVIDER}_CLEAR "$@"
}

_crontab_get() {
	_require "$1" "Crontab User"
	_require "$2" "Crontab Filename to write to"

	_CRONTAB_${_CONF_CRON_PROVIDER}_GET "$@"
}

_crontab_write() {
	_require "$1" "Crontab User"
	_require_file "$2" "Crontab File"

	_CRONTAB_${_CONF_CRON_PROVIDER}_WRITE "$@"
}

_crontab_append() {
	_require "$1" "Crontab User"
	_require_file "$2" "Crontab File"

	_has_contents $2 || return 1

	local current_crontab=$(_SUDO_USER=$1 _mktemp)
	_crontab_get $1 $current_crontab

	_sudo cat $2 | _sudo tee -a $current_crontab >/dev/null 2>&1
	_CRONTAB_${_CONF_CRON_PROVIDER}_WRITE $1 $current_crontab
	_sudo rm -f $current_crontab
}

_CRONTAB_DEFAULT_CLEAR() {
	_SUDO_USER=$1 _sudo crontab -f -r 2>/dev/null
}

_CRONTAB_DEFAULT_GET() {
	_SUDO_USER=$1 _sudo crontab -l >$2 2>/dev/null
}


_CRONTAB_DEFAULT_WRITE() {
	_crontab_default_header $1 $2

	_SUDO_USER=$1 _sudo crontab $2 || {
		_WARN "_ERROR writing crontab"
		_SUDO_USER=$1 _sudo cat $2
	}
}

_crontab_default_header() {

	if [ -n "$_OPTN_INSTALL_CRONTAB_HEADER" ]; then
		printf '%s\n\n' "$_OPTN_INSTALL_CRONTAB_HEADER" | _SUDO_USER=$1 _sudo tee -a $2.new >/dev/null 2>&1
		_SUDO_USER=$1 _sudo cat $2 | _SUDO_USER=$1 _sudo tee -a $2.new >/dev/null 2>&1
		_SUDO_USER=$1 _sudo mv $2.new $2
	fi


	_SUDO_USER=$1 _sudo cat $2 | _SUDO_USER=$1 _sudo tee -a $2.new >/dev/null 2>&1
	_SUDO_USER=$1 _sudo mv $2.new $2
}
