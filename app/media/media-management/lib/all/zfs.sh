_media_drive_create_zfs_snapshot_send() {
  zfs send -v $(zfs list -t snapshot | grep $1@ | tail -1 | awk {'print$1'}) | ssh $media_source_host zfs receive $media_volume_name
}

_media_drive_create_zfs_pool() {
  zpool create -f -o ashift=12 -o autotrim=on -O acltype=posixacl -O xattr=sa -O relatime=on -O compression=zstd -m none $media_volume_name $media_drive
}

_media_drive_create_zfs_datasets() {
  for dataset in $conf_media_management_datasets; do
    _media_drive_create_zfs_snapshot_send $dataset
  done
}

_media_wait_until_resilvered() {
  while [ true ]; do
    zpool status $media_volume_name | $GNU_GREP -Pcqm1 "(action: Wait for the resilver to complete.|scan: resilver in progress since)" && {
      log_debug "sleeping $conf_media_management_zfs_pool_status_interval - waiting for $media_volume_name to resilver"
      sleep $conf_media_management_zfs_pool_status_interval
    }

    log_warn "resilvered $media_volume_name"
    break
  done
}

_media_online_drive() {
  log_info "onlining $media_device_name"
  _media_decrypt_drive
  sudo_run zpool online $media_volume_name $_EXISTING_DEVICE $media_device_name
  log_info "onlined $media_device_name"

  _EXISTING_DEVICE=$(zpool status $media_volume_name | grep ONLINE | grep ada | awk {'print$1'})

  if [ $(zpool status $media_volume_name | $GNU_GREP -P "[\t ]+$media_device_name" | grep -c ONLINE) -eq 0 ]; then
    _online
  else
    log_warn "$media_device_name appears to already be online in $media_volume_name"
  fi
}

_media_offline_drive() {
  log_info "offlining $media_device_name"
  sudo_run zpool offline $media_volume_name $media_device_name

  _media_close_encrypted_drive

  log_info "offlined $media_device_name"
}
