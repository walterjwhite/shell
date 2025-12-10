_system() {
	_hostname
	[ -z "$container" ] && {
		_freebsd_update

		_PACKAGE_INSTALL cpu-microcode || {
			_ERROR "Error installing cpu-microcode"
			return 1
		}

		_enable_cpu_microcode_patches
		_patch_microcode
	}
}

_system_patches() {
	_patches jail kernel periodic rc boot_loader
}

_enable_cpu_microcode_patches() {
	local cpu_vendor=intel
	if [ $(sysctl -a | egrep -i 'hw.model' | grep -ic amd) -gt 0 ]; then
		cpu_vendor=amd
	fi

	printf 'microcode_update_enable="YES"\n' >>/etc/rc.conf

	printf '# freebsd-installer - microcode updates\n' >>/boot/loader.conf

	printf 'cpu_microcode_load="YES"\n' >>/boot/loader.conf
	printf 'cpu_microcode_name="/boot/firmware/%s-ucode.bin"\n' "$cpu_vendor" >>/boot/loader.conf

	_INFO "installed support for patching CPU microcode ($cpu_vendor)"
}

_patch_microcode() {
	_WARN "Patching CPU microcode"
	service microcode_update start
}
