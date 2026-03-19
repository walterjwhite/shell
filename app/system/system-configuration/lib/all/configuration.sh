lib io/file.sh
lib ./sort.sh

_configuration_mac() {
  _mac=$(basename $_client_device_file | sed -e "s/\./\:/g")
}

_configuration_fqdn() {
  _device_name=$(basename $(dirname $_client_device_file))

  zone=$(basename $(dirname $(dirname $_client_device_file)))

  _owner=$(printf '%s' "$_device_name" | cut -d'.' -f 1 | tr '[:upper:]' '[:lower:]')
  _manufacturer=$(printf '%s' "$_device_name" | cut -d'.' -f 2 | tr '[:upper:]' '[:lower:]')
  _name=$(printf '%s' "$_device_name" | cut -d'.' -f 3 | tr '[:upper:]' '[:lower:]')
  _form_factor=$(printf '%s' "$_device_name" | cut -d'.' -f 4 | tr '[:upper:]' '[:lower:]')

  _zone=$(printf '%s' "$zone" | cut -c 1 | tr '[:upper:]' '[:lower:]')
  _mobile_suffix=$(printf '%s' "$zone" | sed -e "s/^.*_mobile/m/")

  if [ "$_mobile_suffix" != "$zone" ]; then
    _zone=${_zone}${_mobile_suffix}
  fi

  if [ $(grep -c ^psk= $_client_device_file) -gt 0 ]; then
    _type="w"

    private_mac=$(grep '^private_mac=.*' $_client_device_file | cut -f2 -d'=')
    [ "$private_mac" ] && _name="$_name-$private_mac"
  else
    _type="l"
  fi

  _hostname=${_owner}-${_manufacturer}-${_name}-${_form_factor}
  _fqdn=${_hostname}.${_zone}.${_type}.${conf_system_configuration_domain_suffix}

  _zone_domain_name=${_zone}.${_type}.${conf_system_configuration_domain_suffix}
}

_configure_devices() {
  file_require "$conf_system_configuration_path/configuration"

  . $conf_system_configuration_path/configuration
  _ip=$_STARTING_IP

  for _client_device_file in $(find $conf_system_configuration_path/devices -type f ! -name '.*'); do
    _configuration_fqdn

    grep -cqm1 '^# STATIC_IP' $_client_device_file || {
      $GNU_SED -i '/_ip=/d' $_client_device_file

      _client_ip=$_IP_PREFIX.$_ip
      printf '_ip=%s\n' "$_client_ip" >>$_client_device_file

      [ -z "$_CLIENT_IP_START" ] && _CLIENT_IP_START=$_client_ip

      _ip=$((_ip + 1))
    }

    $GNU_SED -i '/_fqdn=/d' $_client_device_file
    $GNU_SED -i '/_hostname=/d' $_client_device_file
    $GNU_SED -i '/_DOMAIN=/d' $_client_device_file

    printf '_fqdn=%s\n' "$_fqdn" >>$_client_device_file
    printf '_hostname=%s\n' "$_hostname" >>$_client_device_file
    printf '_DOMAIN=%s\n' "$_zone_domain_name" >>$_client_device_file
  done

  _sorted_devices=$(_sort_by_ip)
  for _client_device_file in $_sorted_devices; do
    local modifier
    . $_client_device_file

    grep -cqm1 '^# STATIC_IP' $_client_device_file && modifier=' [fixed]' || unset modifier

    log_info "device $(basename $_client_device_file) -> ${_ip}${modifier}"

    unset _ip _hostname _DEVICE_ALIASES _domain _fqdn
  done
}

_is_restart_services() {
  [ -n "$_system_configuration_restart_services" ] && return $_system_configuration_restart_services

  local _system_configuration_restart_services=0
  log_warn 'restarting services'

  return 0
}
