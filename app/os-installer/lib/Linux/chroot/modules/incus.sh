_INCUS_OPTIONS='-name *.incus'
_PATCH_INCUS_PRE() {
	_PACKAGE_INSTALL app-containers/incus
	_SERVICE_$_CONF_OS_INSTALLER_INIT incus && _SERVICE_$_CONF_OS_INSTALLER_INIT add incus-user

	grep -qm1 'root:1000000' /etc/subuid || {
		_DETAIL "Configuring users and groups for incus"
		printf 'root:1000000:1000000000\n' | tee -a /etc/subuid /etc/subgid >/dev/null
	}

	[ -n "$OS_INSTALLER_CHROOT" ] && {
		_WARN "The remaining init operations are currently performed after rebooting into the live system"
		return
	}

	_CONF_OS_INSTALLER_MOUNTPOINT=/ _ _incus_live_pre
}

_PATCH_INCUS() {
	[ -n "$OS_INSTALLER_CHROOT" ] && {
		_WARN "The remaining init operations are currently performed after rebooting into the live system"
		return
	}

	_INCUS_CONFIGURATION_FILE=$1
	_ _incus_live "$_INCUS_CONFIGURATION_FILE"
}
