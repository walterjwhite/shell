_hostname() {
	_CONF_OS_INSTALLER_SYSTEM_ID=$(_get_system_id)
	printf '%s-%s\n' $_CONF_OS_INSTALLER_SYSTEM_NAME $_CONF_OS_INSTALLER_SYSTEM_ID >/etc/hostname

	$_CONF_GNU_SED -i "s/^127.0.0.1 localhost$/127.0.0.1  localhost $_CONF_OS_INSTALLER_SYSTEM_NAME-$_CONF_OS_INSTALLER_SYSTEM_ID/" /etc/hosts
}

_get_system_id() {
	dmidecode 2>/dev/null | grep 'Base Board Information' -A10 |
		grep 'Serial Number' | cut -f2 -d':' |
		sed -e 's/^ //' -e 's/ //g' -e 's/\//./g' -e 's/\.//g'
}
