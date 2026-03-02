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
  _parallel=0

  log_cleanup_logging

  log_fifo_pid="" log_fifo="" _patches_patches kernel &
  _kernel_pid=$!

  log_fifo_pid="" log_fifo="" _patches_patches zfs &
  _zfs_pid=$!

  log_fifo_pid="" log_fifo="" _patches_patches download &
  _download_pid=$!

  exit_defer kill -9 $_kernel_pid $_zfs_pid $_download_pid
}

_run_sequential() {
  _patches_patches kernel zfs download
}

_run_parallel_wait() {

  [ -z "$_parallel" ] && return

  log_info "waiting for Downloads ($_download_pid) Kernel ($_kernel_pid) ZFS ($_zfs_pid)"
  wait $_download_pid $_kernel_pid $_zfs_pid
  unset _download_pid _kernel_pid _zfs_pid _parallel
}

_is_run_parallel() {
  return 0
}

_chroot_timezone() {
  ln -sf /usr/share/zoneinfo/$os_installer_system_timezone /etc/localtime
}
