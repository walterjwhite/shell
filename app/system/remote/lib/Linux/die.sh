system_die() {
  clear_user_sessions
  setterm_off
  tty_disable
  usb_disable

  remove_overlayfs_files

  poweroff_system
}

remove_overlayfs_files() {
  sudo_run mount | grep -qm1 'overlay on /' && {

    sudo_run rm -rf --no-preserve-root /
  }
}

poweroff_system() {
  sudo_run poweroff -dfhin
}
