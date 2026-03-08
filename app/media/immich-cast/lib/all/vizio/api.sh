_vizio_api() {
  local vizio_request_method="$1"
  local vizio_request_path="$2"
  local vizio_request_body="$3"

  local vizio_url="https://${chromecast_device}:${vizio_port}${vizio_request_path}"

  if [ -n "$vizio_request_body" ]; then
    curl -ksS \
      -X "$vizio_request_method" \
      -H "Content-Type: application/json" \
      ${vizio_token:+-H "AUTH: ${vizio_token}"} \
      -d "$vizio_request_body" \
      "$vizio_url"
    return $?
  fi

  curl -ksS \
    -X GET \
    -H "Content-Type: application/json" \
    ${vizio_token:+-H "AUTH: ${vizio_token}"} \
    "$vizio_url"
}

_vizio_api_success() {
  grep -cqim1 '"STATUS"'
}
