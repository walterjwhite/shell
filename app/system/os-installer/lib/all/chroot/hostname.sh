_hostname_hostname() {
  if [ -z "$_in_container" ]; then
    conf_os_installer_system_id=$(_hostname_get_system_id)
    conf_os_hostname=$conf_os_installer_system_name-$conf_os_installer_system_id
  else
    conf_os_hostname=$conf_os_installer_system_name
  fi

  printf '%s\n' $conf_os_hostname >/etc/hostname

  $GNU_SED -i "s/^127.0.0.1 localhost$/127.0.0.1 localhost $conf_os_hostname/" /etc/hosts
  $GNU_SED -i "s/^::1 localhost$/::1 localhost $conf_os_hostname/" /etc/hosts
}

_hostname_get_system_id() {
  dmidecode 2>/dev/null | grep 'Base Board Information' -A10 |
    grep 'Serial Number' | cut -f2 -d':' |
    sed -e 's/^ //' -e 's/ //g' -e 's/\//./g' -e 's/\.//g'
}
