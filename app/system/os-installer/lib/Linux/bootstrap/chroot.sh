lib net/download.sh

_init_chroot() {
  _mount_data_cache

  init_chroot_${distribution_function_name}
}

_prepare_chroot() {
  prepare_chroot_${distribution_function_name}
}
