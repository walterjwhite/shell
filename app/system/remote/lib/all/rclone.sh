rclone_copy() {
  [ -z "$rclone_remote" ] && {
    log_warn "rclone_remote is empty"
    return 1
  }

  rclone copy "$@" $rclone_remote:
  return
}

rclone_about() {
  rclone about $rclone_remote:
}
