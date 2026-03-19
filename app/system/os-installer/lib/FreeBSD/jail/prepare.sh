lib ./bootstrap/bootstrap.sh
lib ./bootstrap/chroot.sh
lib ./bootstrap/git.sh
lib ./bootstrap/mount.sh
lib ./git.archive.sh
lib ./run.sh
lib ssh.sh

_jail_setup() {
  log_info "setting up base system in jail"

  conf_os_installer_mountpoint=$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name os_installer_distributions=base _init_chroot

  log_info "setting up DNS in jail"
  printf 'nameserver %s\n' "$conf_os_installer_container_host_ip" >$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/etc/resolv.conf

  target=$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name _ssh_use_host_ssh_conf

  cp $_JAIL_PATH/jail.conf /etc/jail.conf.d/$_jail_install_name.conf

  $GNU_SED -i "s/_DEVFS_RULESET_/$_jail_id/" /etc/jail.conf.d/$_jail_install_name.conf
  $GNU_SED -i "s/_GUEST_IP_/$conf_os_installer_container_guest_ip/" /etc/jail.conf.d/$_jail_install_name.conf

  $GNU_SED -i "s/_JAIL_INSTALL_NAME_/$_jail_install_name/g" /etc/jail.conf.d/$_jail_install_name.conf
  $GNU_SED -i "s/_JAIL_NAME_/$os_installer_jail_name/g" /etc/jail.conf.d/$_jail_install_name.conf

  $GNU_SED -i "s/_JAIL_SUBNET_/$conf_os_installer_container_subnet/" /etc/jail.conf.d/$_jail_install_name.conf
  $GNU_SED -i "s|_JAIL_ZFS_MOUNTPOINT_|$_os_installer_jail_zfs_mountpoint|" /etc/jail.conf.d/$_jail_install_name.conf

}

_jail_install_app() {
  log_info "installing $* in jail"

  _git_system_conf $os_installer_jail_name /$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name

  APP_PLATFORM_ROOT=/$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name log_no_indent=1 app-install "$@"
}

_update_jails_list() {
  local jails=$(sysrc -f /etc/rc.conf -e jail_list | cut -f2 -d'=' | tr -d '"')
  if [ -n "$jails" ]; then
    jails="$jails $os_installer_jail_name"
  else
    jails="$os_installer_jail_name"
  fi

  sysrc -f /etc/rc.conf jail_list="$jails"
}
