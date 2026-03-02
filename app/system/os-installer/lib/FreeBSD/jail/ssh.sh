_jail_enable_bastion_host() {
  _bastion_host=$conf_os_installer_container_host_ip
  _bastion_port=$conf_os_installer_container_host_port
  _bastion_hostnames="$conf_os_installer_container_bastion_hosts"
  _prepare_ssh_conf $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/root root

  exit_defer _jail_disable_bastion_host
}

_jail_disable_bastion_host() {
  log_info "disabling bastion host"

  find $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/root $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $GNU_SED -i 's/^Host/#Host/' {} + 2>/dev/null
  find $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/root $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $GNU_SED -i 's/^ Hostname/# Hostname/' {} + 2>/dev/null
  find $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/root $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $GNU_SED -i 's/^ ProxyJump/# ProxyJump/' {} + 2>/dev/null

  find $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/root $_os_installer_jail_zfs_mountpoint/$os_installer_jail_name/home/* -type f -name config -path '*/.ssh/config' -maxdepth 2 -exec $GNU_SED -i 's/^ User/# User/' {} + 2>/dev/null
}
