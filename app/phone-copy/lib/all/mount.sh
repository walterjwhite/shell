_phone_copy_cleanup() {
	$_SUDO_CMD umount "$_CONF_PHONE_COPY_MOUNT_POINT"
}

_phone_mount() {
	$_SUDO_CMD jmtpfs "$_CONF_PHONE_COPY_MOUNT_POINT" && _defer _phone_copy_cleanup

	$_SUDO_CMD find "$_CONF_PHONE_COPY_MOUNT_POINT" -print -quit >/dev/null 2>&1 || _ERROR "Error checking phone contents"
}
