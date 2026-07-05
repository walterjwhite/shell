_is_run_parallel() {
  local physical_memory=$(sysctl hw.physmem | cut -f2 -d:)
  [ $physical_memory -ge $os_installer_minimum_installation_memory ]
}

_container_mount_points() {
  zfs list -Hr $_os_installer_zfs_pool_name | awk {'print$5'} | grep /jails/

}
