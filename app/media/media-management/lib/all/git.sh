_media_git_init() {
  gclone systems/disks.git
  cd ~/projects/git/systems/disks
}

_media_git_sync() {
  git add .
  git commit -m "update - $media_volume_name"
  git push
}

_media_git_annex() {
  _media_git_annex_do output
  _media_git_annex_do raw
}

_media_git_annex_do() {
  cd $conf_media_mountpoint/$1

  if sudo_user=$conf_media_user sudo_run git status --porcelain | grep -q .; then
    sudo_user=$conf_media_user sudo_run git annex add .
    sudo_user=$conf_media_user sudo_run git commit -am "added media - media-process-staging"

    files_processed=1
  else
    log_info "no changes detected in $1, skipping git operations"
  fi
}
