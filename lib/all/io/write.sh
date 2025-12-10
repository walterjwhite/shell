_append() {
	_sudo tee -a "$1" >/dev/null
}

_write() {
	_sudo tee "$1" >/dev/null
}

_conf_write() {
	_require "$1" "$1 - _CONF_* must not be empty"

	local conf_name

	case $1 in
	_CONF_*)
		conf_name="${1#*_CONF_}"
		;;
	_OPTN_*)
		conf_name="${1#*_OPTN_}"
		;;
	_ST_*)
		conf_name="${1#*_ST_}"
		;;
	*)
		_ERROR "$1 is not a conf (_CONF_), option (_OPTN_), or state (_ST_)"
		;;
	esac

	local conf_file_name="${conf_name%%_*}"
	local conf_value=$(env | grep "$1" | sed -e 's/=.*//')

	[ -f $HOME/.config/walterjwhite/shell/$conf_file_name ] && {
		grep -qm1 $1=.* $HOME/.config/walterjwhite/shell/$conf_file_name && {
			_WARN "Updating existing configuration: $1"
			$_CONF_GNU_SED -i "s/$1=.*/$1=$conf_value/" $HOME/.config/walterjwhite/shell/$conf_file_name
			return
		}
	}

	_DETAIL "Setting configuration: $1"
	printf '%s=%s\n' "$1" "$conf_value" >>$HOME/.config/walterjwhite/shell/$conf_file_name
}
