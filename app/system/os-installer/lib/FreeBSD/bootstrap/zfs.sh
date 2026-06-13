_zfs_create_datasets() {
  zfs create -o mountpoint=none $_os_installer_zfs_pool_name/root
  zfs create -o mountpoint=/ $_os_installer_zfs_pool_name/root/default

  zfs create -o mountpoint=/home -o setuid=off $_os_installer_zfs_pool_name/home


  zfs create -o mountpoint=/usr/ports -p -o setuid=off $_os_installer_zfs_pool_name/usr/ports
  zfs create -o mountpoint=/usr/src $_os_installer_zfs_pool_name/usr/src


  zfs create -o mountpoint=/var/audit -p -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/audit

  zfs create -o mountpoint=/var/cache/pkg -p -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/cache/pkg
  zfs create -o mountpoint=/var/crash -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/crash

  zfs create -o mountpoint=/var/log -o exec=off -o setuid=off $_os_installer_zfs_pool_name/var/log

  zfs create -o mountpoint=/var/mail -o atime=on $_os_installer_zfs_pool_name/var/mail
  zfs create -o mountpoint=/var/tmp -o setuid=off $_os_installer_zfs_pool_name/var/tmp

  zpool set bootfs=$_os_installer_zfs_pool_name/root/default $_os_installer_zfs_pool_name

  zfs set canmount=noauto $_os_installer_zfs_pool_name/root/default
}

_zfs_mount() {
  _zfs_mount_do root/default home usr/ports usr/src var/audit var/cache/pkg var/crash var/log var/mail var/tmp
}
