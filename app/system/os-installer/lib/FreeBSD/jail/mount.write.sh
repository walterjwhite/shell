_jail_write_mounts() {
  [ -n "$_JAIL_PROCFS_ENABLE" ] && _jail_enable_procsfs

  [ -n "$_JAIL_TMPFS_TMPFS_TMP_SIZE" ] && _jail_enable_tmpfs /tmp $_JAIL_TMPFS_TMPFS_TMP_SIZE
  [ -n "$_JAIL_TMPFS_TMPFS_VAR_TMP_SIZE" ] && _jail_enable_tmpfs /var/tmp $_JAIL_TMPFS_TMPFS_VAR_TMP_SIZE
  [ -n "$_JAIL_TMPFS_TMPFS_RUN_SIZE" ] && _jail_enable_tmpfs /run $_JAIL_TMPFS_TMPFS_RUN_SIZE

  [ -n "$_JAIL_PKG_CACHE_ENABLE" ] && _jail_enable_nullfs /var/cache/pkg
  [ -n "$_JAIL_USR_PORTS_ENABLE" ] && _jail_enable_nullfs /usr/ports
  [ -n "$_JAIL_USR_SRC_ENABLE" ] && _jail_enable_nullfs /usr/src
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
