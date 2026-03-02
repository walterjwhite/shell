init_dracut() {
  mkdir -p /etc/dracut.conf.d

  printf 'sys-kernel/installkernel dracut\n' >>/etc/portage/package.use/installkernel

  local dracut_modules
  [ -n "$_os_installer_disk_dev_encrypted" ] && {
    dracut_modules="$dracut_modules crypt "
  }

  [ -n "$_os_installer_zfs_pool_name" ] && {
    [ "$os_installer_boot_fs" = "zpool" ] && {
      dracut_modules="$dracut_modules zfs"
    }
  }

  [ -z "$os_installer_fsck" ] && printf 'nofsck="yes"\n' >>/etc/dracut.conf.d/no-fsck.conf

  printf 'add_dracutmodules+=" %s"\n' "$dracut_modules " >>/etc/dracut.conf.d/modules.conf
}

