_container_mount_points() {
  [ -e /var/lib/incus ] && {
    local container
    for container in $(find /var/lib/incus/storage-pools/default/containers -type d -maxdepth 1 -mindepth 1); do
      printf '%s/rootfs\n' "$container"
    done
  }

  [ -d /var/lib/machines ] && {
    local container
    for container in $(find /var/lib/machines -type d -maxdepth 1 -mindepth 1); do
      printf '%s\n' "$container"
    done
  }
}
