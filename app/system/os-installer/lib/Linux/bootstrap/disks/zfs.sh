_zfs_create_datasets() {
  zfs create -o mountpoint=/ -o canmount=noauto $_os_installer_zfs_pool_name/gentoo
  zfs create -o mountpoint=/home -o setuid=off $_os_installer_zfs_pool_name/home

  zfs create -o mountpoint=/tmp -o exec=on -o setuid=off $_os_installer_zfs_pool_name/tmp

  zfs create -o mountpoint=/usr/src -p -o exec=on -o setuid=off $_os_installer_zfs_pool_name/usr/src

  zfs create -o mountpoint=/var/cache/distfiles -p -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/cache/distfiles
  zfs create -o mountpoint=/var/db/repos -p -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/db/repos
  zfs create -o mountpoint=/var/log -p -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/log
  zfs create -o mountpoint=/var/tmp/portage -p -o setuid=off $_os_installer_zfs_pool_name/var/tmp/portage

  udevadm trigger

  zgenhostid -f
  zpool set bootfs=$_os_installer_zfs_pool_name/gentoo $_os_installer_zfs_pool_name
}

_zfs_mount() {
  _zfs_mount_do gentoo home tmp var/log usr/src var/db/repos var/cache/distfiles var/tmp/portage
}
