_network_on() {
  local gateway=$(route -4n | grep UG | awk {'print$2'})
  [ -z "$gateway" ] && return 1

  ping -q4c1 -w1 $gateway >/dev/null 2>&1
}

_network_restart_services() {
  local _network_service
  for _network_service in $(find /etc/init.d -type l -name 'net.*'); do
    $_network_service restart
  done
}
