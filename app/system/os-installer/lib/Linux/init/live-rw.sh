_linux_live_prepare() {
  mount | awk {'print$3'} | grep -qm1 $conf_os_installer_installer_live_path || {
    _linux_live_open || exit_with_error "failed to open live volume"
  }
}

_linux_live_open() {
  local live_luks_device=$(cat /proc/cmdline | tr ' ' '\n' | grep luks.uuid= | cut -f2 -d=)
  local live_luks_device_path=/dev/disk/by-uuid/$live_luks_device

  log_detail "opening $live_luks_device_path"
  printf '%s' "$_LUKS_KEY" | cryptsetup luksOpen $live_luks_device_path luks-live && exit_defer cryptsetup luksClose luks-live

  log_detail "mounting $conf_os_installer_installer_live_path"
  mount /dev/mapper/luks-live $conf_os_installer_installer_live_path && exit_defer umount $conf_os_installer_installer_live_path
}

_linux_live_remount() {
  log_detail "remounting $conf_os_installer_installer_live_path rw"

  mount -o remount,rw $1 $conf_os_installer_installer_live_path && exit_defer mount -o remount,ro $1 $conf_os_installer_installer_live_path
}
