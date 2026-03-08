package_emerge_install_do() {
  _emerge_portage_sync
  _package_emerge_cmd "$@"
}

package_emerge_uninstall_do() {
  _package_emerge_cmd $emerge_options --depclean "$@"
}

_package_emerge_cmd() {
  [ "$APP_PLATFORM_ROOT" != "/" ] && {
    _emerge_portage_run_in_chroot "$@"
    return
  }

  emerge $EMERGE_FLAGS "$@"
}

_emerge_portage_run_in_chroot() {
  _emerge_portage_setup_chroot_mounts

  chroot $APP_PLATFORM_ROOT emerge $EMERGE_FLAGS "$@"

  _emerge_portage_setup_chroot_mounts_cleanup
}

package_emerge_is_installed() {
  local _package=$1
  shift

  [ -f $APP_PLATFORM_ROOT/var/lib/portage/world ] && {
    $GNU_GREP -Pqm1 "^${_package}$" $APP_PLATFORM_ROOT/var/lib/portage/world && {
      return 0
    }
  }

  local package_group=$(printf '%s' $_package | cut -f1 -d/)
  local package_name=$(printf '%s' $_package | cut -f2 -d/)
  if [ -e $APP_PLATFORM_ROOT/var/db/pkg/$package_group ]; then
    find $APP_PLATFORM_ROOT/var/db/pkg/$package_group -type f -name "$package_name-*.ebuild" | grep -Pqm1 '.' && {
      return 0
    }
  fi
}

package_emerge_bootstrap() {
  [ -n "$emerge_package_disabled" ] && return

  mount | grep ' overlay on / ' | grep -v '/var/lib/docker' | grep -cqm1 '.' && {
    log_warn 'disabling emerge as it appears we are running on an overlayfs'
    emerge_package_disabled=1

    return 1
  }

  _emerge_portage_setup_chroot_mounts_with_root

  _emerge_portage_use_git
  _emerge_portage_mirrors

  _emerge_portage_sync
  _emerge_portage_package_accept_keywords
}

package_emerge_update() {
  _emerge_portage_sync
  log_info "updating world packages"

  _package_emerge_cmd --newuse -uD world "$@"

  log_info "updated world packages"

  if [ -n "$optn_install_gentoo_depclean" ]; then
    log_info "running depclean"
    _package_emerge_cmd $emerge_options --depclean $@
    log_info "depclean completed"
  fi
}

emerge_package_bootstrap_is_package_available() {
  return 0
}

_emerge_portage_setup_chroot_mounts_with_root() {
  [ "$APP_PLATFORM_ROOT" = "/" ] && return

  mkdir -p $APP_PLATFORM_ROOT/dev $APP_PLATFORM_ROOT/run $APP_PLATFORM_ROOT/sys $APP_PLATFORM_ROOT/proc $APP_PLATFORM_ROOT/var/db/repos

  _emerge_portage_mount_rbind dev
  _emerge_portage_mount_rbind run
  _emerge_portage_mount_rbind sys
  mount --types proc /proc $APP_PLATFORM_ROOT/proc

  [ -e /var/db/repos ] && mount --bind /var/db/repos $APP_PLATFORM_ROOT/var/db/repos
}

_emerge_portage_setup_chroot_mounts_cleanup() {
  [ "$APP_PLATFORM_ROOT" = "/" ] && return

  umount -R $APP_PLATFORM_ROOT/dev $APP_PLATFORM_ROOT/run $APP_PLATFORM_ROOT/sys $APP_PLATFORM_ROOT/proc $APP_PLATFORM_ROOT/var/db/repos
}

_emerge_portage_mount_rbind() {
  local mount_point=$1
  mount --rbind /$mount_point $APP_PLATFORM_ROOT/$mount_point
  mount --make-rslave $APP_PLATFORM_ROOT/$mount_point
}
