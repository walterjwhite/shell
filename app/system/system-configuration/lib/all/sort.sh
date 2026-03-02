_sort_by_ip() {
  local temp_file=$(_mktemp_mktemp)
  local client_device_file client_ip

  for client_device_file in $(find $conf_system_configuration_path/devices -type f ! -name '.*'); do
    [ ! -f "$client_device_file" ] && continue

    client_ip=$(grep -h '_ip=' "$client_device_file" | sed -e 's/_ip=//')
    [ -z "$client_ip" ] && continue

    printf '%s %s\n' "$client_ip $client_device_file" >>"$temp_file"
  done

  sort -k1 -V "$temp_file" | awk '{print $2}'

  rm -f "$temp_file"
}
