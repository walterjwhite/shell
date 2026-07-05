

kernel_main_gentoo() {
  _kernel_conf

  _kernel_luks_support
  _package_install_new_only sys-kernel/$os_installer_kernel

  _kernel_zfs_support_gentoo

  _kernel_initramfs
}

_kernel_conf() {
  case $os_installer_init in
  bliss | dracut | ugrd)
    printf 'USE="$USE %s"\n' "$os_installer_init" >>/etc/portage/make.conf
    ;;
  esac

  case $os_installer_kernel in
  *-kernel | *-kernel-bin)
    _os_installer_dist_kernel=1
    printf 'USE="$USE dist-kernel"\n' >>/etc/portage/make.conf
    ;;
  *)
    printf 'USE="$USE symlink"\n' >>/etc/portage/make.conf
    ;;
  esac
}

_kernel_manual_build() {
  case $os_installer_kernel in
  *-kernel | *-kernel-bin) ;;
  *)

    log_detail "building kernel $os_installer_kernel"
    local opwd=$PWD

    cd /usr/src/linux
    cp /tmp/gentoo/system/kernel.config .

    make && make modules_install && make install

    cd $opwd
    ;;
  esac
}

_kernel_zfs_support_gentoo() {
  [ "$os_installer_boot_fs" != "zpool" ] && {
    log_warn "boot -> $os_installer_boot_fs, skipping ZFS"
    return 1
  }

  [ -z "$_os_installer_zfs_pool_name" ] && {
    log_warn "pool name not set: $_os_installer_zfs_pool_name, skipping ZFS"
    return 2
  }

  [ -n "$_os_installer_dist_kernel" ] && {
    [ -z "$_in_container" ] && {
      printf 'sys-fs/zfs dist-kernel-cap\n' >>/etc/portage/package.use/zfs
    }
  }

  _package_install_new_only sys-fs/zfs-kmod
  _package_install_new_only sys-fs/zfs

  _kernel_zfs_service_systemd
}

_kernel_zfs_service_systemd() {
  systemctl enable zfs.target
  systemctl enable zfs-import-cache
  systemctl enable zfs-mount
  systemctl enable zfs-import.target

  systemctl enable zfs-trim-monthly@${_os_installer_zfs_pool_name}.timer
  systemctl enable zfs-scrub-monthly@${_os_installer_zfs_pool_name}.timer

  systemctl enable zfs-trim-weekly@${_os_installer_zfs_pool_name}.timer
  systemctl enable zfs-scrub-weekly@${_os_installer_zfs_pool_name}.timer
}

_kernel_luks_support() {
  [ -n "$_os_installer_disk_dev_encrypted" ] && _package_install_new_only sys-fs/cryptsetup
}

_kernel_initramfs() {
  init_$os_installer_init

  case $os_installer_init in
  bliss | dracut | ugrd)
    emerge --config sys-kernel/$os_installer_kernel
    ;;
  esac
}
