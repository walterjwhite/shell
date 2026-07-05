lib fs/zfs.sh
lib jail.sh

_prune_jail_snapshot_destroy() {
  log_warn "destroying Jail Snapshot $_JAIL_ZFS_SNAPSHOT - created $_ZFS_SNAPSHOT_CR_DT ($_ZFS_SNAPSHOT_AGE_HUMAN)"
  zfs destroy $_JAIL_ZFS_SNAPSHOT
}

_prune_jail_snapshot_by_age() {
  log_info "pruning jail snapshots by age"

  for _JAIL_PATH in $(_get_jail_paths); do
    _jail_volume=$(_get_jail_volume $_JAIL_PATH)

    log_info "pruning jail snapshots for: $_jail_volume"
    for _JAIL_ZFS_SNAPSHOT in $(zfs list -H -t snapshot -o name $_jail_volume); do
      _zfs_snapshot_details

      if [ $_ZFS_SNAPSHOT_AGE -gt $conf_system_maintenance_jail_SNAPSHOT_EXPIRATION_PERIOD ]; then
        _prune_jail_snapshot_destroy
      else
        log_debug "retaining snapshot: $_JAIL_ZFS_SNAPSHOT $_ZFS_SNAPSHOT_CR_DT $_ZFS_SNAPSHOT_AGE_HUMAN"
      fi

      _jail_snapshot_cleanup
    done
  done
}

_prune_jail_snapshot_by_number() {
  if [ -z "$conf_system_maintenance_max_jail_snapshot_to_keep" ]; then
    return 1
  fi

  log_info "pruning jail snapshots by count"
  for _JAIL_PATH in $(_get_jail_paths); do
    _jail_volume=$(_get_jail_volume $_JAIL_PATH)

    log_info "pruning jail snapshots for: $_jail_volume"
    for _JAIL_ZFS_SNAPSHOT in $(zfs list -H -t snapshot -o name $_jail_volume | tail -r | tail -n +$conf_system_maintenance_max_jail_snapshot_to_keep | tail -r); do
      _zfs_snapshot_details
      _prune_jail_snapshot_destroy

      _jail_snapshot_cleanup
    done
  done
}

_jail_snapshot_cleanup() {
  unset _JAIL_ZFS_SNAPSHOT _ZFS_SNAPSHOT_CR_DT _ZFS_SNAPSHOT_AGE _ZFS_SNAPSHOT_AGE_HUMAN
}
