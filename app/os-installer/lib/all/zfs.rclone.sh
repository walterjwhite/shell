_zfs_rclone() {
	local rclone_patch_path=patches/zfs-rclone.patch/package
	mkdir -p $(dirname $rclone_patch_path)

	if [ -n "$_ZFS_RCLONE_TARGET" ]; then
		_INFO "Configuring ZFS rclone target: $_ZFS_RCLONE_TARGET on $_ZFS_VOLUME"

		[ ! -e $rclone_patch_path ] && printf 'net-misc/rclone\n' >>$rclone_patch_path

		zfs set rclone:target=$_ZFS_RCLONE_TARGET $_ZFS_VOLUME
	fi

	[ -n "$_ZFS_RCLONE_PATH" ] && zfs set rclone:path=$_ZFS_RCLONE_PATH $_ZFS_VOLUME

	unset _ZFS_RCLONE_PATH _ZFS_RCLONE_TARGET
}
