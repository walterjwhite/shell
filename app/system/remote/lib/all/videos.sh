videos_queue() {
  [ -n "$REMOTE_VIDEOS_DOWNLOAD_USER" ] && {
    log_warn "running as $REMOTE_VIDEOS_DOWNLOAD_USER"

    export sudo_user=$REMOTE_VIDEOS_DOWNLOAD_USER
    sudo_run vq "$@"
    return $?
  }

  vq "$@"
}
