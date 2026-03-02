patch_post_run() {
  _module_find_callback _post_run_do

  _post_run_restore_ssh
}

_post_run_do() {
  cd $conf_os_installer_system_workspace
  . $1
}

_post_run_restore_ssh() {
  log_detail "restoring SSH configuration (if applicable)"

  [ -e /root/.ssh.restore ] && _post_run_restore_ssh_do /root

  [ ! -e /home ] && return

  for s in $(find /home -type d -depth 2 -name '.ssh.restore'); do
    _post_run_restore_ssh_do $(dirname $s)
  done
}

_post_run_restore_ssh_do() {
  log_warn "removing setup .ssh with .ssh.restore [$1]"
  rm -rf $1/.ssh
  mv $1/.ssh.restore $1/.ssh
}
