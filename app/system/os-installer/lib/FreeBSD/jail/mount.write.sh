_jail_write_mounts() {
  [ -n "$jail_procfs_enable" ] && _jail_enable_procsfs

  [ -n "$jail_tmpfs_tmpfs_tmp_size" ] && _jail_enable_tmpfs /tmp $jail_tmpfs_tmpfs_tmp_size
  [ -n "$jail_tmpfs_tmpfs_var_tmp_size" ] && _jail_enable_tmpfs /var/tmp $jail_tmpfs_tmpfs_var_tmp_size
  [ -n "$jail_tmpfs_tmpfs_run_size" ] && _jail_enable_tmpfs /run $jail_tmpfs_tmpfs_run_size

  [ -n "$jail_pkg_cache_enable" ] && _jail_enable_nullfs /var/cache/pkg
  [ -n "$jail_usr_ports_enable" ] && _jail_enable_nullfs /usr/ports
  [ -n "$jail_usr_src_enable" ] && _jail_enable_nullfs /usr/src
}

_jail_update_mount_point() {
  $GNU_SED -i 's/".*\/jails/"\/jails/' /etc/jail.conf.d/$os_installer_jail_name.conf
  $GNU_SED -i 's/ .*\/jails/ \/jails/' $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name.fstab
}

_jail_update_post_jail() {
  $GNU_SED -i "s/^#_POST_JAIL_#//" /etc/jail.conf.d/$os_installer_jail_name.conf
  $GNU_SED -i 's/^\(.*#_POST_JAIL_SETUP_DISABLE_#\)$/#\1/' /etc/jail.conf.d/$os_installer_jail_name.conf $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name.fstab
}

_jail_enable_procsfs() {
  printf 'proc %s/proc procfs ro 0 0\n' $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name >>$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name.fstab
}

_jail_enable_tmpfs() {
  mkdir -p $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$1
  printf 'tmpfs %s tmpfs rw,mode=1777,size=%s 0 0\n' $1 $2 >>$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name.fstab
}

_jail_enable_nullfs() {
  printf '%s %s%s nullfs rw 0 0\n' "$1" "$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name" "$1" >>$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name.fstab
}
