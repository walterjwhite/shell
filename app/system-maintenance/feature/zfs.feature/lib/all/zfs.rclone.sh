_zfs_rclone() {
	for _ZFS_VOLUME in $(zfs list -H | awk {'print$1'}); do
		_RCLONE_TARGET=$(_zfs_get_property rclone:target $_ZFS_VOLUME)

		[ "$_RCLONE_TARGET" = "-" ] && continue


		_INFO "rclone - [$_RCLONE_TARGET]"
		_DETAIL "rclone - $_RCLONE_TARGET:$_ZFS_VOLUME - $1 - start"

		zfs_rclone_$1

		_DETAIL "rclone - $_RCLONE_TARGET:$_ZFS_VOLUME - $1 - end [$?]"
	done
}
