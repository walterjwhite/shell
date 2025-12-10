_PACKAGE_UPDATE() {
	_PACKAGE_BOOTSTRAP
	_sudo pkg $_PKG_OPTIONS upgrade $_FREEBSD_PKG_OPTIONS $@
	_sudo pkg $_PKG_OPTIONS autoremove $_FREEBSD_PKG_OPTIONS $@
}

_PACKAGE_INSTALL_DO() {
	_PACKAGE_BOOTSTRAP
	_sudo pkg $_PKG_OPTIONS install $_FREEBSD_PKG_OPTIONS $@
}

_PACKAGE_UNINSTALL() {
	_PACKAGE_BOOTSTRAP
	_sudo pkg $_PKG_OPTIONS delete $_FREEBSD_PKG_OPTIONS $@
}

_PACKAGE_IS_INSTALLED() {
	_PACKAGE_BOOTSTRAP
	pkg $_PKG_OPTIONS _INFO -e $1 2>/dev/null
}

_PACKAGE_BOOTSTRAP() {
	[ $_PKG_BOOTSTRAPPED ] && return

	ASSUME_ALWAYS_YES=yes
	_PKG_BOOTSTRAPPED=1

	if [ -n "$_ROOT" ] && [ "$_ROOT" != "/" ]; then
		_package_cache_already_mounted || _package_cache_mount
		_PKG_OPTIONS="-r $_ROOT"
	fi

	_package_enable_proxy

	_sudo pkg $_PKG_OPTIONS update -q
}

_package_cache_already_mounted() {
	mount | awk {'print$3'} | grep -q "$_ROOT/var/cache/pkg$"
}

_package_cache_mount() {
	[ -e /sbin/mount_nullfs ] || return 1
	[ -e /var/cache/pkg ] || return 1

	_sudo mkdir -p $_ROOT/var/cache/pkg

	_INFO "Mounting host's package cache"
	_sudo mount -t nullfs /var/cache/pkg $_ROOT/var/cache/pkg || {
		_WARN "Error mounting host's package cache"
		_WARN "pkg cache mounts: $(mount | awk {'print$3'} | grep \"^$_ROOT/var/cache/pkg$\")"
		_WARN "mounts: $(mount | awk {'print$3'})"
		_WARN "/var/cache/pkg:"
		return 1
	}

	_defer _package_cache_umount

	_INFO "Mounted host's package cache"
}

_package_cache_umount() {
	umount $_ROOT/var/cache/pkg
}

__PACKAGE_BOOTSTRAP_IS_PACKAGE_AVAILABLE() {
	return 0
}

_package_enable_proxy() {
	[ -z "$http_proxy" ] && return 1
	[ $_PKG_PROXY_ENABLED ] && return 2

	_PKG_PROXY_ENABLED=1
	_defer _package_disable_proxy
	_WARN "[install] Configuring pkg to use an HTTP proxy: $http_proxy"

	local _updated_package_conf=$(_mktemp)
	if [ -e $_ROOT/usr/local/etc/pkg.conf ]; then
		grep -v '^pkg_env' $_ROOT/usr/local/etc/pkg.conf >$_updated_package_conf
		mv $_updated_package_conf $_ROOT/usr/local/etc/pkg.conf
	fi

	mkdir -p $_ROOT/usr/local/etc
	printf 'pkg_env: { http_proxy: "%s"}\n' "$http_proxy" >>$_ROOT/usr/local/etc/pkg.conf
}

_package_disable_proxy() {
	[ -z "$http_proxy" ] && return 1

	unset _PKG_PROXY_ENABLED
	_WARN "[freebsd-installer] Disabling HTTP proxy: $http_proxy"
	$_CONF_GNU_SED -i "s/^pkg_env/#pkg_env/" $_ROOT/usr/local/etc/pkg.conf
}
