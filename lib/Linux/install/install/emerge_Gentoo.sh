_PACKAGE_UPDATE() {
	_portage_sync
	_INFO "updating world packages"
	_sudo emerge $_EMERGE_FLAGS $_EMERGE_OPTIONS --newuse -uD world $@
	_INFO "updated world packages"

	if [ -n "$_OPTN_INSTALL_GENTOO_DEPCLEAN" ]; then
		_INFO "running depclean"
		_sudo emerge $_EMERGE_FLAGS $_EMERGE_OPTIONS --depclean $@
		_INFO "depclean completed"
	fi
}

_PACKAGE_INSTALL_DO() {
	_portage_sync
	_sudo emerge $_EMERGE_FLAGS $_EMERGE_OPTIONS $@
}

_PACKAGE_UNINSTALL() {
	_portage_sync
	_sudo emerge $_EMERGE_FLAGS $_EMERGE_OPTIONS --depclean $@
}

_PACKAGE_IS_INSTALLED() {
	[ -f $_ROOT/var/lib/portage/world ] && {
		$_CONF_GNU_GREP -Pqm1 "^${1}$" $_ROOT/var/lib/portage/world && {
			return 0
		}
	}

	local package_group=$(printf '%s' $1 | cut -f1 -d/)
	local package_name=$(printf '%s' $1 | cut -f2 -d/)
	if [ -e $_ROOT/var/db/pkg/$package_group ]; then
		find $_ROOT/var/db/pkg/$package_group -type f -name "$package_name-*.ebuild" | grep -Pqm1 '.' && {
			return 0
		}
	fi

	return 1
}

_PACKAGE_BOOTSTRAP() {
	mount | grep -qm1 'overlay on /' && {
		_WARN 'Disabling emerge as it appears we are running on an overlayfs'
		_PACKAGE_DISABLED=1

		return 1
	}

	_portage_use_git
	_portage_mirrors

	_portage_sync
	_portage_package_accept_keywords
}

_portage_sync() {
	_EMERGE_SYNC_FILE=$_ROOT/var/cache/.portage.sync.time
	_portage_synced && {
		_DEBUG "portage was already synced today"
		return
	}

	_sudo mkdir -p $(dirname $_EMERGE_SYNC_FILE)
	_sudo emerge $_EMERGE_FLAGS $_EMERGE_OPTIONS --sync && {
		date +%s | _write "$_EMERGE_SYNC_FILE"
	}
}

_portage_synced() {
	[ ! -e $_EMERGE_SYNC_FILE ] && return 1

	local last_synced=$(head -1 $_EMERGE_SYNC_FILE)
	local current_time=$(date +%s)

	[ $(($current_time - $last_synced)) -gt $PORTAGE_REFRESH_PERIOD ] && return 1

	return 0
}

_portage_use_git() {
	[ -e $_ROOT/etc/portage/repos.conf/gentoo.conf ] && return 0

	rm -rf $_ROOT/etc/portage/repos.conf && mkdir -p $_ROOT/etc/portage/repos.conf
	printf '
  [DEFAULT]
  main-repo = gentoo

  [gentoo]
  location = /var/db/repos/gentoo
  sync-type = git
  sync-uri = https://github.com/gentoo-mirror/gentoo.git
  auto-sync = yes
  sync-git-verify-commit-signature = yes
  sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
  ' >$_ROOT/etc/portage/repos.conf/gentoo.conf

	rm -rf $_ROOT/var/db/repos/gentoo/* && _portage_sync
}

_portage_mirrors() {
	[ "$_ROOT" = "/" ] && return

	[ ! -e /etc/portage/make.conf ] && return

	grep -qm1 '^GENTOO_MIRRORS=.*$' /etc/portage/make.conf || return

	grep -qm1 '^GENTOO_MIRRORS=.*$' $_ROOT/etc/portage/make.conf && return

	printf '# mirror from host\n' >>$_ROOT/etc/portage/make.conf
	grep '^GENTOO_MIRRORS=.*$' /etc/portage/make.conf >>$_ROOT/etc/portage/make.conf
}

_portage_package_accept_keywords() {
	[ -e $_ROOT/etc/portage/package.accept_keywords/platform ] && return

	_sudo mkdir -p $_ROOT/etc/portage/package.accept_keywords /etc/portage/package.accept_keywords

	printf '%s\n' "$_PLATFORM_PACKAGES_ACCEPT_KEYWORDS" | _append $_ROOT/etc/portage/package.accept_keywords/platform

	printf '%s\n' "$_PLATFORM_PACKAGES_ACCEPT_KEYWORDS" | _append /etc/portage/package.accept_keywords/platform
}

_PACKAGE_BOOTSTRAP_IS_PACKAGE_AVAILABLE() {
	return 0
}
