_BOOT_LOADER_EXEC="$_CONF_APPLICATION_LIBRARY_PATH/bin/_key_value /boot/loader.conf {} sysctl ;"

_BOOT_LOADER_SUPPORTS_JAILS=1

_PATCH_BOOT_LOADER_POST() {
	[ -z "$_IN_JAIL" ] && return 1

	_WARN "Moving configuration to /tmp/jail/boot_loader to be picked up by host"
	mkdir -p /tmp/jail
	mv /boot/loader.conf /tmp/jail/boot_loader
}

_PATCH_BOOT_LOADER_JAILS() {
	_DETAIL "Appending jail boot loader confs"

	local jail_mountpoint
	for jail_mountpoint in $(_jail_mount_points); do
		local boot_loader_jail_conf=$jail_mountpoint/tmp/jail/boot_loader

		if [ -e $boot_loader_jail_conf ]; then
			_DETAIL "Appending jail boot loader conf: $jail_mountpoint"
			printf '\n\n# %s jail boot_loader configuration\n' $jail_mountpoint >>/boot/loader.conf

			cat $boot_loader_jail_conf >>/boot/loader.conf
		fi
	done
}
