_network_online() {
  [ -n "$skip_connectivity_check" ] && return

  curl --connect-timeout $conf_network_test_timeout -fs $(_network_select_random_host) >/dev/null 2>&1 || return 1
}

_network_select_random_host() {
  local _host_count
  _host_count=$(printf '%s\n' $conf_network_test_targets | tr ' ' '\n' | wc -l | awk {'print$1'})

  local _random_index
  _random_index=$(shuf -i 1-$_host_count -n 1)

  printf '%s\n' $conf_network_test_targets | tr ' ' '\n' | tail +$_random_index | head -1
}
