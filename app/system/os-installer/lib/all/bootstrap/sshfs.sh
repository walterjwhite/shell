_mount_data_cache() {
  df -h -t $os_installer_sshfs_type $APP_PLATFORM_CACHE_PATH >/dev/null 2>&1 && return 0

  _mount_sshfs_cache_do '' $APP_PLATFORM_CACHE_PATH
}

_mount_sshfs_cache() {
  _mount_sshfs_cache_do $conf_os_installer_mountpoint $os_installer_cache_fses
}

_mount_sshfs_cache_do() {
  [ -z "$os_installer_cache_enabled" ] && return 1
  [ -z "$os_installer_cache_fses" ] || [ -z "$os_installer_cache_path" ] && return 2

  ssh $os_installer_cache ls $os_installer_cache_path >/dev/null 2>&1 || {
    local sshfs_status=$?
    log_warn "cache path $os_installer_cache_path not found on $os_installer_cache"

    return $sshfs_status
  }

  local _cache_prefix=$1
  shift

  local cache_fs
  for cache_fs in $@; do
    mkdir -p $_cache_prefix/${cache_fs}

    ssh $os_installer_cache mkdir -p $os_installer_cache_path/$APP_PLATFORM_PLATFORM/$APP_PLATFORM_SUB_PLATFORM/${cache_fs} >/dev/null 2>&1 || return $?

    sshfs -o StrictHostKeyChecking=no $os_installer_sshfs_options $os_installer_cache:$os_installer_cache_path/$APP_PLATFORM_PLATFORM/$APP_PLATFORM_SUB_PLATFORM/${cache_fs} \
      $_cache_prefix/${cache_fs} && exit_defer "umount:$_cache_prefix/${cache_fs}"
  done
  unset _cache_prefix cache_fs sshfs_status
}
