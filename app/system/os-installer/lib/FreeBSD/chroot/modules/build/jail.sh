lib install

jail_type=d
jail_path=jail

patch_jail() {
  [ -n "$_in_container" ] && return

  _jail_init
  _jail_init_networking
  _jail_init_ssh
  _jail_init_dns
  _jail_init_proxy

  _environment_export_matching_vars os_installer

  _module_find -exec $APP_LIBRARY_PATH/bin/jail-setup {} \;

  _patch_jail_post
}

_jail_init() {
  local _os_installer_jail_zfs_dataset=$_os_installer_zfs_pool_name/jails
  zfs create -o mountpoint=/jails $_os_installer_jail_zfs_dataset

  local _os_installer_jail_zfs_mountpoint=$(zfs list -H -o mountpoint $_os_installer_jail_zfs_dataset)

  sysrc -f /etc/rc.conf jail_enable=YES

  _package_install_new_only unbound tinyproxy || exit_with_error "error setting up jail proxy"
}

_jail_init_networking() {
  ifconfig lo1 create
  ifconfig lo1 $conf_os_installer_container_host_ip netmask $conf_os_installer_container_subnet up
}

_jail_init_ssh() {
  printf 'Port %s\n' "$conf_os_installer_container_host_port" >>/etc/ssh/sshd_config

  chmod 400 /etc/ssh/ssh_host*

  service sshd onestart

  log_debug "appending SSH key to authorized keys"
  cat ~/.ssh/id_*.pub >>~/.ssh/authorized_keys

  chmod 600 ~/.ssh/authorized_keys
  mkdir -p ~/.ssh/socket
  chmod 700 ~/.ssh/socket
}

_jail_init_dns() {
  local _upstream_dns_server=$(grep nameserver /etc/resolv.conf | cut -f2 -d ' ')

  printf 'server:\n' >/usr/local/etc/unbound/unbound.conf
  printf '\tinterface: %s\n' "$conf_os_installer_container_host_ip" >>/usr/local/etc/unbound/unbound.conf
  printf '\taccess-control: %s allow\n' $conf_os_installer_container_access_network >>/usr/local/etc/unbound/unbound.conf
  printf 'forward-zone:\n' >>/usr/local/etc/unbound/unbound.conf
  printf '\tname: "."\n' >>/usr/local/etc/unbound/unbound.conf
  printf '\tforward-addr: %s\n' "$_upstream_dns_server" >>/usr/local/etc/unbound/unbound.conf

  log_warn "using $_upstream_dns_server as the upstream DNS server"

  service unbound onestart
}

_jail_init_proxy() {
  printf 'Allow %s\n' $conf_os_installer_container_access_network >>/usr/local/etc/tinyproxy.conf
  printf 'upstream none "."\n' >>/usr/local/etc/tinyproxy.conf

  service tinyproxy onestart

  export http_proxy=$conf_os_installer_container_host_ip:$conf_os_installer_container_proxy_port
  export https_proxy=$conf_os_installer_container_host_ip:$conf_os_installer_container_proxy_port
}

_patch_jail_post() {
  unset http_proxy https_proxy

  service sshd onestop
  service tinyproxy onestop
  service unbound onestop

  _package_uninstall_do unbound tinyproxy

  ifconfig lo1 destroy

  rm -rf /usr/local/etc/unbound
  rm -rf /usr/local/etc/tinyproxy.conf
  rm -f /var/log/tinyproxy.log

  rmuser -y unbound

  $GNU_SED -i 's/^Port/# Port/' /etc/ssh/sshd_config

  unset _os_installer_jail_zfs_dataset _os_installer_jail_zfs_mountpoint
}

_jail_mount_points() {
  zfs list -Hr $_os_installer_zfs_pool_name | awk {'print$5'} | grep /jails/
}
