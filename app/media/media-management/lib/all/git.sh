_media_git_init() {
  gclone systems/disks.git
  cd ~/projects/git/systems/disks
}

_media_git_sync() {
  git add .
  git commit -m "update - $media_volume_name"
  git push
}
