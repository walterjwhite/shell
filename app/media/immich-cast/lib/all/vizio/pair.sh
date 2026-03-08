_vizio_do_pair() {
  log_detail "pairing request to $chromecast_device:$vizio_port ..."

  _vizio_api PUT /pairing/cancel \
    "{\"DEVICE_ID\": \"${vizio_device_id}\"}"

  response=$(_vizio_api PUT /pairing/start \
    "{\"DEVICE_ID\":\"${vizio_device_id}\",\"DEVICE_NAME\":\"${vizio_device_name}\"}")

  printf '%s' "$response" | grep -qi '"STATUS"' || {
    log_warn "raw response: $response"
    exit_with_error "no response from TV."
  }

  pair_token=$(printf '%s' "$response" | grep -o '"PAIRING_REQ_TOKEN": [0-9]*' | grep -o '[0-9]*$')
  validation_require "$pair_token" "pair_token: $response"

  _stdin_read_if "enter 4-digit pin" _vizio_pin
  _vizio_pin=$(printf '%s' "$_vizio_pin" | tr -d '[:space:]')

  response2=$(_vizio_api PUT /pairing/pair \
    "{\"DEVICE_ID\":\"${vizio_device_id}\",\"CHALLENGE_TYPE\":1,\"RESPONSE_VALUE\":\"${_vizio_pin}\",\"PAIRING_REQ_TOKEN\":${pair_token}}")

  vizio_token=$(printf '%s' "$response2" | grep -o '"AUTH_TOKEN": "[^"]*"' | cut -d'"' -f4)
  [ -z "$vizio_token" ] && exit_with_error "pairing failed. Wrong PIN? | $response2"

  log_detail "successfully paired: token: $vizio_token"
}
