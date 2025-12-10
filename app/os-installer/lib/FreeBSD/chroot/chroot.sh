_chroot_init() {

	app-install install os-installer
}

_is_run_parallel() {
	local physical_memory=$(sysctl hw.physmem | cut -f2 -d:)
	[ $physical_memory -ge $FREEBSD_MINIMUM_INSTALLATION_MEMORY ]
}
