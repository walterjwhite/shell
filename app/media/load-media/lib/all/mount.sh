_load_media_cleanup() {
  umount $conf_load_media_mount_point
}

_load_media_mount() {
  mkdir -p $conf_load_media_mount_point

  case $conf_media_copy_fs in
  fat)
    $conf_media_copy_fat_mount_cmd $conf_load_media_mount_point
    ;;
  mtp)
    jmtpfs "$conf_load_media_mount_point"
    ;;
  esac

  [ $? -eq 0 ] || exit_with_error 'exit_with_error mounting media'

  exit_defer _load_media_cleanup

  find "$conf_load_media_mount_point" -maxdepth 1 -mindepth 1 -print -quit >/dev/null 2>&1 || exit_with_error "error checking phone contents"
}

_load_media_is_mounted() {
  mount | grep -cqm1 " on $conf_load_media_mount_point "
}
