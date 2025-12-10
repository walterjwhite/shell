_cleanup_processes() {
	local os_installer_process=$(ps aux | grep tail | grep $_CONF_OS_INSTALLER_MOUNTPOINT | awk {'print$2'})
	[ -n "$os_installer_process" ] && kill -9 $os_installer_process

	killall gpg-agent >/dev/null 2>&1
	killall keyboxd >/dev/null 2>&1

	killall ssh-agent >/dev/null 2>&1
}
