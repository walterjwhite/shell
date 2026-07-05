_zfs_get_property() {
  zfs get -H $1 $2 | awk {'print$3'}
}

_zfs_snapshot_details() {
  zfs_snapshot_cr_dt=$(zfs get -H -p creation $jail_zfs_snapshot | awk {'print$3'})

  zfs_snapshot_age=$(($current_epoch_time - $zfs_snapshot_cr_dt))

  _time_seconds_to_human_readable $zfs_snapshot_age
  zfs_snapshot_age_human=$human_readable_time
  unset human_readable_time
}

_zfs_is_volume_jailed() {
  local zfs_mount_point=$(zfs list -H $zfs_volume | awk {'print$5'})
  if [ ! -e $zfs_mount_point ]; then
    log_warn "$zfs_volume appears to be jailed, skipping - $(zfs get -H jailed $zfs_volume | awk {'print$3'}))"
    return 0
  fi

  return 1
}

_zfs_system_pool() {
  zfs list -H | awk {'print$1'} | grep ROOT$ | sed -e 's/\/ROOT//'
}
