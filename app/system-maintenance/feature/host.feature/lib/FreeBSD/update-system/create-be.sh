_reboot() {
	if [ -n "$_REBOOT_REQUIRED" ]; then
		system=$_LOGGING_CONTEXT _system_alert "reboot is required" "$_REBOOT_REQUIRED"

		if [ -n "$_FIRST_BOOT" ]; then
			_ reboot
		else
			_WARN "not rebooting - $_CONF_SYSTEM_MAINTENANCE_REBOOT"
			_success "please reboot to install updates [$_REBOOT_REQUIRED]"
		fi
	fi

	unset _REBOOT_REQUIRED
}

_create_be() {
	[ -n "$_ON_JAIL" ] && {
		_create_be_jail "$1"
		return
	}

	_create_be_physical "$1"
}

_create_be_jail() {
	local target_jail_snapshot=$_JAIL_VOLUME@$1

	local latest_jail_snapshot=$(zfs list -H -t snapshot $_JAIL_VOLUME | tail -1 | awk {'print$1'})
	if [ "$latest_jail_snapshot" = "$target_jail_snapshot" ]; then
		_INFO "jail snapshot ($target_jail_snapshot) already exists"
		return
	fi

	_ zfs snapshot $target_jail_snapshot

	if [ -n "$_FIRST_BOOT" ]; then
		_WARN "initializing patch sequence: $_LAST_SEQUENCE_FILE"
		printf 'create-be\n' >$_LAST_SEQUENCE_FILE
		printf '%s\n' "$(date)" >>$_LAST_SEQUENCE_FILE
	fi


	local jail_update
	for jail_update in $SYSTEM_UPDATES; do
		patch_${jail_update}
		[ -n "$_CHECK_RESTART" ] && _checkrestart

		unset _CHECK_RESTART
	done

	date >>$_LAST_SEQUENCE_FILE
	_reboot
}

_create_be_physical() {
	if [ $(beadm list -H | awk {'print$1'} | grep -c $1) -lt 1 ]; then
		if [ -n "$_FIRST_BOOT" ]; then
			_WARN "initializing patch sequence: $_LAST_SEQUENCE_FILE"
			printf 'create-be\n' >$_LAST_SEQUENCE_FILE
			printf '%s\n' "$(date)" >>$_LAST_SEQUENCE_FILE

			_REBOOT_REQUIRED="First Boot, create BE"
		else
			_REBOOT_REQUIRED="$SYSTEM_UPDATES updates available"
		fi

		local securelevel=$(sysrc kern_securelevel_enable | awk {'print$2'})
		if [ "$securelevel" = "YES" ]; then
			sysrc kern_securelevel_enable=NO
			_WARN "TODO: Please run sysrc kern_securelevel_enable=YES to re-enable securelevel"
		fi

		_update_host $1
		_reboot
	else
		_WARN "BE: $1 already exists."
	fi
}

_update_host() {
	_ beadm create $1

	_ beadm mount $1
	local be_mount_point=$(mount | grep $1 | head -1 | awk {'print$3'})

	_ mount -t nullfs /usr/src $be_mount_point/usr/src
	$_CONF_APPLICATION_LIBRARY_PATH/apply_patches.expect $1 $_LAST_SEQUENCE_FILE "$SYSTEM_UPDATES"

	umount $be_mount_point/usr/src

	_ beadm activate $1
}
