_live_update_esp() {
  [ -z "$os_installer_esp_uuid" ] && {
    log_warn "no ESP specified, not automatically updating"
    return 1
  }

  log_detail "eSP specified: $os_installer_esp_uuid"
  mkdir -p /mnt/esp
  mount /dev/disk/by-uuid/$os_installer_esp_uuid /mnt/esp && exit_defer _live_cleanup_esp

  mkdir -p /mnt/esp/EFI/gentoo/$_os_installer_latest_kernel_version

  _gentoo_latest_kernel_version

  cp /boot/vmlinuz-$_os_installer_latest_kernel_version /mnt/esp/EFI/gentoo/$_os_installer_latest_kernel_version/_KERNEL
  cp $_INIT_OUTPUT_FILE /mnt/esp/EFI/gentoo/$_os_installer_latest_kernel_version/initramfs
  cp /boot/System.map-$_os_installer_latest_kernel_version /mnt/esp/EFI/gentoo/$_os_installer_latest_kernel_version/System.map
  cp /boot/config-$_os_installer_latest_kernel_version /mnt/esp/EFI/gentoo/$_os_installer_latest_kernel_version/config
}

_live_cleanup_esp() {
  umount /mnt/esp
}

_live_update_boot_volume() {
  [ -z "$os_installer_live_uuid" ] && {
    log_warn "no Live UUID specified, not automatically updating"
    return 1
  }

  _os_installer_live_device=/dev/disk/by-uuid/$os_installer_live_uuid
  [ "$conf_os_installer_installer_live_use_encryption" = "y" ] && {
    cryptsetup luksOpen /dev/disk/by-uuid/$os_installer_live_uuid live && exit_defer _live_cleanup_crypt

    _os_installer_live_device=/dev/mapper/live
  }

  mkdir -p /mnt/live
  mount $_os_installer_live_device /mnt/live && exit_defer _live_cleanup_boot

  mkdir -p /mnt/live

  _live_update_data root $os_installer_root_squash_output_file
}

_live_update_data() {
  local image_install_path=/mnt/live/.$(date +%Y.%m.%d.%H_%M_%S)-$1.img.$conf_os_installer_installer_live_compression_type

  log_detail "copying image to: $image_install_path"
  cp -a $2 $image_install_path

  log_detail "updating link to squashfs.img"
  ln -f $image_install_path /mnt/live/$1-squashfs.img
}

_live_cleanup_crypt() {
  cryptsetup luksClose live
}

_live_cleanup_boot() {
  umount /mnt/live
}

_gentoo_latest_kernel_version() {
  _os_installer_latest_kernel_version=$(find /boot -type f -name 'vmlinuz*' ! -name '*.old' | sed -e 's/^.*vmlinuz-//')
}

_live_efibootmgr() {
  [ "$conf_os_installer_installer_update_efi" != "y" ] && {
    log_warn "not updating EFI"
    return 1
  }

  _os_installer_boot_loader_args="luks.uuid=$os_installer_live_uuid"

  efibootmgr --create --disk $os_installer_disk_device \
    --label "Gentoo live - $_os_installer_latest_kernel_version" --loader "\\EFI\\gentoo\\$_os_installer_latest_kernel_version\\kernel" \
    --unicode "initrd=\\EFI\\gentoo\\$_os_installer_latest_kernel_version\\initramfs $_os_installer_boot_loader_args"
}
