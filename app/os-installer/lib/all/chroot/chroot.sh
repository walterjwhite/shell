_chroot_init() {
	:
}

_run_parallel() {
	_is_run_parallel && {
		_run_parallel_do
		return
	}

	_run_sequential
}

_run_parallel_do() {
	_PARALLEL=0

	_patches _kernel &
	_KERNEL_PID=$!

	_patches zfs &
	_ZFS_PID=$!

	_patches download &
	_DOWNLOAD_PID=$!

}

_run_sequential() {
	_patches _kernel zfs download
}

_run_parallel_wait() {
	_PRESERVE_LOG=1 _set_logfile $_ORIGINAL_LOGFILE

	[ -n "$_PARALLEL" ] && {
		_INFO "Waiting for Downloads ($_DOWNLOAD_PID) Kernel ($_KERNEL_PID) ZFS ($_ZFS_PID)"
		wait $_DOWNLOAD_PID $_KERNEL_PID $_ZFS_PID
		unset _DOWNLOAD_PID _KERNEL_PID _ZFS_PID _PARALLEL
	}
}

_is_run_parallel() {
	return 0
}
