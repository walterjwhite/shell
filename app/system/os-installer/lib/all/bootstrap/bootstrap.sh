lib ./git.archive.sh
lib net/network.sh
lib ssh.sh
lib system.sh

_bootstrap_validate() {
  validation_require "$os_installer_disk_passphrase" os_installer_disk_passphrase

  local incorrect_prefix=$(printf '%s' "$conf_os_installer_disk_dev_name" | grep -c ^z_)
  [ "$incorrect_prefix" -gt "0" ] && conf_os_installer_disk_dev_name=$(printf '%s' "$conf_os_installer_disk_dev_name" | sed -e "s/^z_//")

  _network_online
}

_init_chroot_net() {
  [ -e $conf_os_installer_mountpoint/etc/resolv.conf ] && {
    readlink $conf_os_installer_mountpoint/etc/resolv.conf >/dev/null 2>&1 && {
      mv $conf_os_installer_mountpoint/etc/resolv.conf $conf_os_installer_mountpoint/etc/resolv.conf.bak
      exit_defer _init_chroot_net_cleanup
    }
  }

  cp --dereference /etc/resolv.conf $conf_os_installer_mountpoint/etc
}

_init_chroot_net_cleanup() {
  mv $conf_os_installer_mountpoint/etc/resolv.conf.bak $conf_os_installer_mountpoint/etc/resolv.conf
}

_init_chroot_other() {
  [ -e /etc/hostid ] && cp /etc/hostid $conf_os_installer_mountpoint/etc
}

_init_chroot_app_conf() {
  _git_system_conf $conf_os_installer_system_name $conf_os_installer_mountpoint
  log_no_indent=1 APP_PLATFORM_ROOT=$conf_os_installer_mountpoint \
    app-install install os-installer || exit_with_error 'error bootstrapping os-install'
}

_init_chroot_ssh() {
  [ "$conf_os_installer_mountpoint" = "/" ] && return

  [ -e $conf_os_installer_mountpoint/etc/ssh ] && {
    cp /etc/ssh/sshd_config $conf_os_installer_mountpoint/etc/ssh/sshd_config
  }

  mkdir -p $conf_os_installer_mountpoint/root/.ssh/socket
  cp /root/.ssh/id* \
    /root/.ssh/authorized_keys \
    /root/.ssh/known_hosts \
    $conf_os_installer_mountpoint/root/.ssh

  target=$conf_os_installer_mountpoint _ssh_use_host_ssh_conf
}

_write_system() {
  APP_PLATFORM_ROOT=$conf_os_installer_mountpoint system_write_id $conf_os_installer_system_name $conf_os_installer_system_ref $conf_os_installer_system_git
}

_run_init() {
  _os_installer_exec_dir=$conf_os_installer_execution_log/$conf_os_installer_disk_dev_name
  mkdir -p $_os_installer_exec_dir
}
