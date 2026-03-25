_pkg_package_cache_already_mounted() {
  mount | awk '{print$3}' | grep -q "$root/var/cache/pkg$"
}

_pkg_package_cache_mount() {
  [ -e /sbin/mount_nullfs ] || return 1
  [ -e /var/cache/pkg ] || return 1

  mkdir -p "$root/var/cache/pkg"

  log_info "mounting host's package cache"
  mount -t nullfs /var/cache/pkg "$root/var/cache/pkg" || {
    log_warn "failed to mount host's package cache"
    log_warn "pkg cache mounts: $(mount | awk '{print$3}' | grep "^$root/var/cache/pkg$")"
    log_warn "mounts: $(mount | awk '{print$3}')"
    log_warn "package cache directory: /var/cache/pkg"
    return 1
  }

  exit_defer "umount:$root/var/cache/pkg"

  log_info "mounted host's package cache"
}
