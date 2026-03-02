lib ./git.archive.sh

_mount_install_media() {
  mkdir -p $os_installer_drive_mount_point
  mount /dev/${os_installer_drive}${os_installer_drive_device_path} $os_installer_drive_mount_point || exit_with_error "unable to mount USB volume"
}

_copy_conf() {
  log_info "copying conf"

  _git_system_conf $conf_os_installer_system_name $conf_os_installer_mountpoint
  _copy_ssh_conf
}

_copy_ssh_conf() {
  [ -e $os_installer_drive_mount_point/root/.ssh ] && {
    log_warn "sSH configuration already exists, skipping"
    return
  }

  mkdir -p $os_installer_drive_mount_point/root/.ssh

  _copy_if_not_the_same $os_installer_drive_mount_point/root/.ssh \
    $HOME/.ssh/id_ed25519 \
    $HOME/.ssh/id_ed25519.pub \
    $HOME/.ssh/known_hosts \
    $HOME/.ssh/authorized_keys

  return 0
}

_copy_if_not_the_same() {
  local _target_directory=$1
  shift

  local source_file
  for source_file in "$@"; do
    local filename=$(basename "$source_file")
    [ -e $_target_directory/$filename ] && cmp -s "$source_file" "$_target_directory/$filename" >/dev/null 2>&1 && continue

    mkdir -p "$_target_directory"
    cp "$source_file" "$_target_directory/$filename"
  done
  unset _target_directory source_file filename
}
