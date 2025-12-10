lib ./zfs.rclone.sh
lib ./zfs.zap.sh

_ZFS_SUPPORTS_JAILS=1

_PATCH_ZFS() {
	local zfs_volume_configuration
	for zfs_volume_configuration in $@; do
		if [ -n "$_IN_JAIL" ]; then
			mkdir -p /tmp/jail/zfs
			cp $zfs_volume_configuration /tmp/jail/zfs

			local zfs_volume_configuration_name=$(basename $zfs_volume_configuration)

			printf '_ZFS_JAILED=1\n' >>/tmp/jail/zfs/$zfs_volume_configuration_name
			printf '_ZFS_JAIL=%s\n' $_JAIL_NAME >>/tmp/jail/zfs/$zfs_volume_configuration_name
			printf '_ZFS_VOLUME_NAME=jails/%s/$_ZFS_VOLUME_NAME\n' $_JAIL_NAME >>/tmp/jail/zfs/$zfs_volume_configuration_name
		else
			_zfs_restore $zfs_volume_configuration
			unset _ZFS_DEV_NAME _ZFS_SOURCE_HOST _ZFS_VOLUME_NAME _ZFS_VOLUME_ABORT_CREATE _ZFS_ZAP_SNAP _ZFS_ZAP_TTL _ZFS_ZAP_BACKUP _ZFS_MOUNT_POINT _ZFS_VOLUME
		fi
	done
}

_PATCH_ZFS_JAILS() {
	_DETAIL "Processing jail ZFS configurations"
	local jail_mountpoint
	for jail_mountpoint in $(_jail_mount_points); do
		local zfs_jail_conf=$jail_mountpoint/tmp/jail/zfs

		if [ -e $zfs_jail_conf ]; then
			_DETAIL "Processing jail ZFS configuration: $zfs_jail"
			_ZFS $(find $zfs_jail_conf -type f 2>/dev/null)
		fi
	done
}

_zfs_restore() {
	_INFO "_zfs_restore: $1"

	mkdir -p ~/.ssh/socket
	chmod 700 ~/.ssh/socket

	. $1

	[ -z "$_ZFS_DEV_NAME" ] && {
		_WARN "_ZFS_DEV_NAME is empty"
		return 1
	}

	[ -z "$_ZFS_SOURCE_HOST" ] && {
		_WARN "_ZFS_SOURCE_HOST is empty"
		return 1
	}

	[ -z "$_ZFS_VOLUME_NAME" ] && {
		_WARN "_ZFS_VOLUME_NAME is empty"
		return 1
	}

	_ZFS_VOLUME=${_ZFS_DEV_NAME}/$_ZFS_VOLUME_NAME
	_ZFS_SOURCE_SNAPSHOT=$(ssh $_ZFS_SOURCE_HOST zfs list -H -t snapshot | grep $_ZFS_VOLUME_NAME@ | grep -v backups | tail -1 | awk {'print$1'})

	[ -z "$_ZFS_SOURCE_SNAPSHOT" ] && {
		_WARN "No snapshots available, unable to setup clone: $_ZFS_VOLUME"
		return 1
	}

	_zfs_has_sufficient_space || return 1

	_INFO "zfs create $_ZFS_VOLUME"

	zfs create -p $_ZFS_VOLUME
	[ -n "$_ZFS_MOUNT_POINT" ] && zfs set mountpoint=$_ZFS_MOUNT_POINT $_ZFS_VOLUME
	[ -n "$_ZFS_JAILED" ] && zfs set jailed=on $_ZFS_VOLUME

	zfs set readonly=on $_ZFS_VOLUME

	ssh $_ZFS_SOURCE_HOST zfs send -v $_ZFS_SOURCE_SNAPSHOT | zfs receive -F $_ZFS_VOLUME

	zfs allow -g wheel bookmark,diff,hold,send,snapshot $_ZFS_VOLUME

	if [ -n "$_ZFS_SNAPSHOT_USER" ]; then
		mkdir -p $OS_INSTALLER_SYSTEM_WORKSPACE/patches/any/zfs-snapshot-user.patch/run/

		printf 'zfs allow -u %s bookmark,diff,hold,send,snapshot %s' $_ZFS_SNAPSHOT_USER $_ZFS_VOLUME \
			>>$OS_INSTALLER_SYSTEM_WORKSPACE/patches/any/zfs-snapshot-user.patch/run/allow-zfs-snapshot-user

		chmod +x $OS_INSTALLER_SYSTEM_WORKSPACE/patches/any/zfs-snapshot-user.patch/run/allow-zfs-snapshot-user
	fi

	_zfs_zap
	_zfs_rclone


	_INFO "zfs create $_ZFS_VOLUME - done"
}

_zfs_has_sufficient_space() {
	_ZFS_SNAPSHOT_SPACE=$(ssh $_ZFS_SOURCE_HOST zfs list -t snapshot $_ZFS_SOURCE_SNAPSHOT | awk '{print$4}' | grep "G$" | sed -e "s/G$//")

	_ZFS_SNAPSHOT_REQUIRED_SPACE=$(printf '2 * %s\n' "$_ZFS_SNAPSHOT_SPACE" | bc)
	_ZPOOL_FREE_SPACE=$(zpool list -H $_ZFS_DEV_NAME | awk '{print$4}' | grep "G$" | sed -e "s/G$//")
	if [ $(printf '%s < %s\n' "$_ZFS_SNAPSHOT_REQUIRED_SPACE" "$_ZPOOL_FREE_SPACE" | bc) -eq 0 ]; then
		_WARN "Insufficient free space: $_ZFS_VOLUME_NAME - $_ZFS_SNAPSHOT_SPACE $_ZFS_SNAPSHOT_REQUIRED_SPACE $_ZPOOL_FREE_SPACE"
		return 1
	fi

	_INFO "Setting up $_ZFS_VOLUME_NAME - $_ZFS_SNAPSHOT_SPACE $_ZFS_SNAPSHOT_REQUIRED_SPACE $_ZPOOL_FREE_SPACE"
}
