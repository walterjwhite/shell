sysklogd_get_and_reset() {
  sudo_run find /var/log -type f -name log -print -exec cat {} \;

  sudo_run find /var/log -type f -name log -exec truncate -s 0 {} +

}
