lib io/write.sh

_pkg_enable_proxy() {
  [ -z "$http_proxy" ] && return 1
  [ "$pkg_proxy_enabled" ] && return 2

  pkg_proxy_enabled=1
  exit_defer _pkg_disable_proxy
  log_warn "configuring pkg to use HTTP proxy: $http_proxy (via [install])"

  local _updated_package_conf
  _updated_package_conf=$(_mktemp_mktemp)
  if [ -e "$root/usr/local/etc/pkg.conf" ]; then
    grep -v '^pkg_env' "$root/usr/local/etc/pkg.conf" >"$_updated_package_conf"
    mv "$_updated_package_conf" "$root/usr/local/etc/pkg.conf"
  fi

  mkdir -p "$root/usr/local/etc"
  printf 'pkg_env: { http_proxy: "%s"}\n' "$http_proxy" >>"$root/usr/local/etc/pkg.conf"
}

_pkg_disable_proxy() {
  [ -z "$http_proxy" ] && return 1

  unset pkg_proxy_enabled
  log_warn "disabling HTTP proxy: $http_proxy (via [freebsd-installer])"
  "$GNU_SED" -i "s/^pkg_env/#pkg_env/" "$root/usr/local/etc/pkg.conf"
}
