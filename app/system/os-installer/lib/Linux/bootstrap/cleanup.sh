_cleanup_processes() {
  local os_installer_process=$(ps aux | grep tail | grep $conf_os_installer_mountpoint | awk {'print$2'})
  [ -n "$os_installer_process" ] && kill -9 $os_installer_process 2>/dev/null

  killall gpg-agent >/dev/null 2>&1
  killall keyboxd >/dev/null 2>&1

  killall ssh-agent >/dev/null 2>&1
}
