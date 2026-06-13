_emerge_portage_mirrors() {
  [ "$APP_PLATFORM_ROOT" = "/" ] && return

  [ ! -e /etc/portage/make.conf ] && return

  grep -qm1 '^GENTOO_MIRRORS=.*$' /etc/portage/make.conf || return

  grep -qm1 '^GENTOO_MIRRORS=.*$' $APP_PLATFORM_ROOT/etc/portage/make.conf && return

  printf '# mirror from host\n' >>$APP_PLATFORM_ROOT/etc/portage/make.conf
  grep '^GENTOO_MIRRORS=.*$' /etc/portage/make.conf >>$APP_PLATFORM_ROOT/etc/portage/make.conf
}

_emerge_portage_package_accept_keywords() {
  [ -e $APP_PLATFORM_ROOT/etc/portage/package.accept_keywords/platform ] && return

  mkdir -p $APP_PLATFORM_ROOT/etc/portage/package.accept_keywords /etc/portage/package.accept_keywords

  printf '%s\n' "$emerge_PLATFORM_PACKAGES_accept_keywords" >>$APP_PLATFORM_ROOT/etc/portage/package.accept_keywords/platform

  printf "$emerge_PLATFORM_PACKAGES_accept_keywords" >>/etc/portage/package.accept_keywords/platform
}
