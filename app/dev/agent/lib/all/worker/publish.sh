lib net/rclone.sh

_worker_publish_artifacts() {
  [ -z "$rclone_remote" ] && {
    log_warn "unable to publish: rclone_remote is undefined"
    return 1
  }


  _rclone_prune_stale_files
  publish
}
