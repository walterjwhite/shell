_jail_mounts() {
  _jail_mount_host_all
  _jail_mount_procfs
  _jail_mount procfs proc proc


}

_jail_mount_host_all() {
  _jail_mount_host var/cache/pkg
  _jail_mount_host usr/src
  _jail_mount_host usr/ports
}

_jail_mount_host() {
  [ -e /sbin/mount_nullfs ] || return 1
  [ -e /var/cache/pkg ] || return 1

  local target=$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$1
  mkdir -p $target

  log_detail "mounting host $1 -> $target"
  mount -t nullfs /$1 $target || {
    log_warn "error mounting host $1"
    log_warn "$1 mounts: $(mount | awk {'print$3'} | grep \"^$target$\")"
    log_warn "mounts: $(mount | awk {'print$3'})"
    return 1
  }

  exit_defer umount:$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$1
  log_detail "mounted host $1"
}

_jail_mount() {
  log_detail "mounting $1 @ $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$3"
  mkdir -p $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$3
  mount -t $1 $2 $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$3 || {
    log_warn "error mounting $1 @ $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$3"
    return 1
  }

  exit_defer umount:$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/$3
}
