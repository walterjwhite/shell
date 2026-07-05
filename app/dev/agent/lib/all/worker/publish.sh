lib net/rclone.sh

_worker_publish_artifacts() {
  #
  if [ -n "$rclone_remote" ]; then
    _rclone_prune_stale_files
  else
    log_detail "rclone_remote not configured — skipping rclone-specific pruning"
  fi

  publish
}
