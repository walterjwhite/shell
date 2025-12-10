_load_modules() {
	lsmod | grep -qm1 ^iptable_filter || modprobe iptable_filter
	lsmod | grep -qm1 ^ip6table_filter || modprobe ip6table_filter
	lsmod | grep -qm1 ^br_netfilter || modprobe br_netfilter
}

_import_gentoo_gpg_keys() {
	gpg --import /usr/share/openpgp-keys/gentoo-release.asc

	_defer _gpg_kill
}

_gpg_verify() {
	_require "$1" "File to verify with GPG"

	local gpg_output=$(gpg --verify "$1" 2>&1)
	local gpg_status=$?
	[ $gpg_status -gt 0 ] && {
		_ERROR "$gpg_output" $gpg_status
	}

	_DETAIL "GPG verification completed"
}

_networking() {
	dhcpcd $_INTERFACE
}

_validate_conf() {
	_require "$GENTOO_INIT" "GENTOO_INIT"
	_value_in "$GENTOO_INIT" "BLISS|DRACUT|UGRD|WALTERJWHITE"

	_require "$GENTOO_BOOT_LOADER" "GENTOO_BOOT_LOADER"
	_value_in "$GENTOO_BOOT_LOADER" "EFIBOOTMGR|GRUB"

	_require "$GENTOO_CRON" "GENTOO_CRON [cronie|dcron|fcron|bcron|anacron]"
	_value_in "$GENTOO_CRON" "cronie|dcron|fcron|bcron|anacron"

	_require "$GENTOO_SYSLOG" "GENTOO_SYSLOG [sysklogd|syslog-ng|rsyslog|metalog]"
	_value_in "$GENTOO_SYSLOG" "sysklogd|syslog-ng|rsyslog|metalog"

	_require "$GENTOO_KERNEL" "GENTOO_KERNEL [gentoo-kernel]"
	_value_in "$GENTOO_KERNEL" "gentoo-kernel"
}
