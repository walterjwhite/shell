lib ./zfs.rclone.sh
lib ./zfs.zap.sh

patch_zfs() {
  _module_find_callback _zfs_restore_do

  [ -z "$_in_container" ] && _zfs_handle_containers

  return 0
}

_zfs_restore_do() {
  local _zfs_volume_configuration=$1
  shift

  if [ -n "$_in_container" ]; then
    log_warn "processing jail ZFS configuration: $_zfs_volume_configuration"

    printf '_ZFS_JAILED=1\n' >>$_zfs_volume_configuration
    printf '_ZFS_JAIL=%s\n' $os_installer_jail_name >>$_zfs_volume_configuration
    printf '_ZFS_VOLUME_PREFIX=jails/%s\n' $os_installer_jail_name >>$_zfs_volume_configuration

    unset _zfs_volume_configuration
    return
  fi

  _zfs_restore
  unset _zfs_volume_configuration _ZFS_DEV_NAME _ZFS_SOURCE_HOST _ZFS_VOLUME_NAME _ZFS_VOLUME_ABORT_CREATE _ZFS_ZAP_SNAP _ZFS_ZAP_TTL _ZFS_ZAP_BACKUP _ZFS_MOUNT_POINT _zfs_volume _ZFS_JAILED _ZFS_JAIL
}

_zfs_handle_containers() {
  log_detail "processing container ZFS configurations"
  local container_mountpoint
  for container_mountpoint in $(_container_mount_points); do
    local container_name=$(basename $container_mountpoint)
    local zfs_container_path=$container_mountpoint/tmp/os

    if [ -e $zfs_container_path ]; then
      log_detail "processing container ZFS configuration: $container_name"
      local container_zfs_config
      for container_zfs_config in $(find $zfs_container_path -type f -path '*/zfs/*' 2>/dev/null); do
        _zfs_restore_do $container_zfs_config
      done
    fi
  done
}

_zfs_restore() {
  log_info "zfs_restore: $_zfs_volume_configuration"

  mkdir -p ~/.ssh/socket
  chmod 700 ~/.ssh/socket

  . $_zfs_volume_configuration

  [ -z "$_ZFS_DEV_NAME" ] && {
    log_warn "zfs_dev_name is empty"
    return 1
  }

  [ -z "$_ZFS_SOURCE_HOST" ] && {
    log_warn "zfs_source_host is empty"
    return 1
  }

  [ -z "$_ZFS_VOLUME_NAME" ] && {
    log_warn "zfs_volume_name is empty"
    return 1
  }

  if [ -n "$_ZFS_VOLUME_PREFIX" ]; then
    local _zfs_volume=${_ZFS_DEV_NAME}/${_ZFS_VOLUME_PREFIX}/$_ZFS_VOLUME_NAME
  else
    local _zfs_volume=${_ZFS_DEV_NAME}/$_ZFS_VOLUME_NAME
  fi

  local _zfs_source_snapshot=$(ssh $_ZFS_SOURCE_HOST zfs list -H -t snapshot | grep $_ZFS_VOLUME_NAME@ | grep -v backups | tail -1 | awk {'print$1'})

  [ -z "$_zfs_source_snapshot" ] && {
    log_warn "no snapshots available, unable to setup clone: $_zfs_volume"
    return 1
  }

  _zfs_has_sufficient_space || return 1

  local zfs_options
  zfs get -H encryption $_ZFS_DEV_NAME | awk {'print$4'} | grep -cqm1 '^off$' || {
    zfs_options=" -x encryption "
  }

  log_info "zfs create $_zfs_volume"
  ssh $_ZFS_SOURCE_HOST zfs send -v $_zfs_source_snapshot | zfs receive $zfs_options $_zfs_volume

  zfs set readonly=on $_zfs_volume

  [ -n "$_ZFS_MOUNT_POINT" ] && zfs set mountpoint=$_ZFS_MOUNT_POINT $_zfs_volume
  [ -n "$_ZFS_JAILED" ] && zfs set jailed=on $_zfs_volume

  zfs allow -g wheel bookmark,diff,hold,send,snapshot $_zfs_volume

  if [ -n "$_ZFS_SNAPSHOT_USER" ]; then
    mkdir -p $conf_os_installer_system_workspace/patches/any/zfs-snapshot-user-AUTO.patch/run/

    printf 'zfs allow -u %s bookmark,diff,hold,send,snapshot %s\n\n' $_ZFS_SNAPSHOT_USER $_zfs_volume \
      >>$conf_os_installer_system_workspace/patches/any/zfs-snapshot-user-AUTO.patch/run/allow-zfs-snapshot-user

    chmod +x $conf_os_installer_system_workspace/patches/any/zfs-snapshot-user-AUTO.patch/run/allow-zfs-snapshot-user
  fi

  _zfs_zap
  _zfs_rclone


  log_info "zfs create $_zfs_volume - done"
}

_zfs_has_sufficient_space() {
  local _zfs_snapshot_space=$(ssh $_ZFS_SOURCE_HOST zfs list -t snapshot $_zfs_source_snapshot | awk '{print$4}' | grep "G$" | sed -e "s/G$//")

  local _zfs_snapshot_required_space=$(printf '2 * %s\n' "$_zfs_snapshot_space" | bc)
  local _zpool_free_space=$(zpool list -H $_ZFS_DEV_NAME | awk '{print$4}' | grep "G$" | sed -e "s/G$//")
  if [ $(printf '%s < %s\n' "$_zfs_snapshot_required_space" "$_zpool_free_space" | bc) -eq 0 ]; then
    log_warn "insufficient free space: $_ZFS_VOLUME_NAME - $_zfs_snapshot_space $_zfs_snapshot_required_space $_zpool_free_space"
    return 1
  fi

  log_info "setting up $_ZFS_VOLUME_NAME - $_zfs_snapshot_space $_zfs_snapshot_required_space $_zpool_free_space"
}
