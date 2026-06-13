_setup_zfs_dataset_in_jail() {
  mkdir -p /usr/local/etc/walterjwhite/jails/$os_installer_jail_name/created /usr/local/etc/walterjwhite/jails/$os_installer_jail_name/prestop

  printf 'zfs jail %s %s\n' $os_installer_jail_name "$1" >>/usr/local/etc/walterjwhite/jails/%s/created/jail-$2
  printf 'jexec %s zfs mount %s\n' $os_installer_jail_name "$1" >>/usr/local/etc/walterjwhite/jails/%s/created/jail-$2
  chmod +x /usr/local/etc/walterjwhite/jails/$os_installer_jail_name/created/jail-$2

  printf 'zfs unjail %s %s\n' $os_installer_jail_name "$1" /prestop/jail-$2 >>/usr/local/etc/walterjwhite/jails/$os_installer_jail_name
  chmod +x /usr/local/etc/walterjwhite/jails/$os_installer_jail_name /prestop/jail-$2
}
