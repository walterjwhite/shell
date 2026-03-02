_validate_disk() {
  local root_fstype=$(mount | grep ' on / ' | sed -e 's/ type//' | awk {'print$4'} | sed -e 's/(//' -e 's/,//')
  local root_device=$(mount | grep ' on / ' | awk {'print$1'})

  case $root_fstype in
  zfs)
    local pool_name="${root_device%%/*}"
    local pool_device=$(zpool status $pool_name | grep NAME -A10 | grep $pool_name -A1 | sed 1d | awk {'print$1'})

    local underlying_device=$(_get_underlying_device $pool_device)

    [ "/dev/$underlying_device" = "$conf_os_installer_disk_dev" ] && exit_with_error "unable to install on $conf_os_installer_disk_dev, same as root device: $underlying_device"
    ;;
  ufs)
    ;;
  *)
    exit_with_error "unknown rootfs: $root_fstype"
    ;;
  esac
}
