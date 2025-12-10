_KERNEL_TYPE=d
_KERNEL_PATH=kernel
_KERNEL_SUPPORTS_JAILS=1

_PATCH_KERNEL() {
	if [ -z "$_IN_JAIL" ]; then
		_KERNEL_PATCH_PATH=$OS_INSTALLER_SYSTEM_WORKSPACE/patches/physical/kernel-auto-generated.patch/_kernel _kernel_append "$@"
	else
		_KERNEL_PATCH_PATH="/tmp/jail/kernel" _kernel_append "$@"
	fi
}

_PATCH_KERNEL_JAILS() {
	_DETAIL "Processing jail kernel configurations"
	local jail_mountpoint
	for jail_mountpoint in $(_jail_mount_points); do
		local kernel_jail_conf=$jail_mountpoint/tmp/jail/kernel

		_KERNEL_PATCH_PATH=$OS_INSTALLER_SYSTEM_WORKSPACE/patches/physical/kernel-auto-generated.patch/_kernel _kernel_append $kernel_jail_conf
	done
}

_kernel_append() {
	mkdir -p $_KERNEL_PATCH_PATH

	_DETAIL "Appending kernel conf to: $_KERNEL_PATCH_PATH"

	find "$@" -type f -path '*/kernel/kernel' -exec $_CONF_GNU_GREP -Pvh '(^#|^$)' {} + >>$_KERNEL_PATCH_PATH/kernel 2>/dev/null
	find "$@" -type f -path '*/kernel/modules' -exec $_CONF_GNU_GREP -Pvh '(^#|^$)' {} + >>$_KERNEL_PATCH_PATH/modules 2>/dev/null
}
