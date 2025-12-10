_sysklogd() {
	find /var/log -type f -name log -print -exec cat {} \;

	find /var/log -type f -name log -exec truncate -s 0 {} +

	/etc/init.d/sysklogd restart
}
