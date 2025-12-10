_post_install() {
	umask 077
	for i in /entropy /boot/entropy; do
		i="$_CONF_OS_INSTALLER_MOUNTPOINT/$i"
		dd if=/dev/random of="$i" bs=4096 count=1
		chown 0:0 "$i"
	done
}
