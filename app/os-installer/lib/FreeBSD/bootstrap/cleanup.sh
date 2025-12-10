_cleanup_processes() {
	ps aux | grep tail | grep -qm1 $_CONF_OS_INSTALLER_MOUNTPOINT || return 0

	kill -9 $(ps aux | grep tail | grep $_CONF_OS_INSTALLER_MOUNTPOINT | awk {'print$2'})
}
