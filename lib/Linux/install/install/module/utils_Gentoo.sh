_get_feature_name() {
	case $1 in
	*feature*)
		printf '%s' "$1" | sed \
			-e 's/^.*\/feature\///' \
			-e 's/.feature\/.*//' \
			-e 's/^/./' \
			-e 's/\//./g'
		;;
	*)
		printf ''
		;;
	esac
}

_gentoo_portage_install_file() {
	_sudo mkdir -p /etc/portage/$1
	_sudo cp $2 /etc/portage/$1/app.$_TARGET_APPLICATION_NAME$(_get_feature_name $2)
}

_gentoo_portage_uninstall_file() {
	_sudo rm -f /etc/portage/$1/app.$_TARGET_APPLICATION_NAME$(_get_feature_name $2)
}

_gentoo_portage_is_installed() {
	[ -e /etc/portage/$1/app.$_TARGET_APPLICATION_NAME$(_get_feature_name $2) ]
}
