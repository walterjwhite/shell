_freebsd_mount_usb_media_rw() {
  sudo_run mount -o rw /
}

_freebsd_mount_usb_media_ro() {
  sudo_run mount -o ro /
}

readlink /etc/resolv.conf >/dev/null 2>&1 && {
  readonly FREEBSD_IS_INSTALL_MEDIA=1

  [ -n "$APP_PLATFORM_ROOT" ] && [ "$APP_PLATFORM_ROOT" != "/" ] && {
    freebsd_pkg_suffix=_install_media
    _freebsd_mount_usb_media_rw && exit_defer _freebsd_mount_usb_media_ro
  }
}
