_PATCH_FREEBSD() {
	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS install

	if [ $? -eq 2 ]; then
		_WARN "no updates available, fetch first"
		return
	fi

	_REBOOT_REQUIRED="FreeBSD updated"
	_CHECK_RESTART=1
}

_PATCH_FREEBSD_UPGRADE() {
	_patch_freebsd_upgrade_do upgrade install
}

_patch_freebsd_upgrade_install() {
	_patch_freebsd_upgrade_do install kernel
}

_PATCH_FREEBSD_UPGRADE_KERNEL() {
	_patch_kernel
}

_patch_freebsd_upgrade_do() {
	_require "$_PATCH_ARGUMENTS" _PATCH_ARGUMENTS

	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS $1 -r $_PATCH_ARGUMENTS

	if [ $? -eq 2 ]; then
		_WARN "no upgrades available"
		return
	fi

	_REBOOT_REQUIRED="FreeBSD Upgrade ${1}ed"
	_CHECK_RESTART=0

	_patch_be
}

_PATCH_USERLAND() {
	_ pkg $_PKG_UPDATE_OPTIONS upgrade -y
	_CHECK_RESTART=1
}

_PATCH_KERNEL() {
	if [ -n "$_ON_JAIL" ]; then
		_ERROR "Cannot update kernel for jail - $_JAIL_NAME"
	fi

	cd /usr/src

	_ git reset --hard HEAD

	rm -f $(git status | grep '^??' | grep -v sys/conf/amd64/custom)

	local system_version=$(uname -r | sed -e 's/-RELEASE.*//')
	_ git checkout releng/$system_version
	_ git pull

	KERNCONF=custom
	_ make buildkernel && make installkernel

	_INFO "Rebuilt kernel, please reboot to use patched kernel"
	_REBOOT_REQUIRED="Kernel updated"
}

_PATCH_NOOP() {
	_WARN "This is a noop patch for test purposes"
}
