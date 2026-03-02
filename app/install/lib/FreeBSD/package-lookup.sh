_lookup_package() {
  _lookup_pkg_using_ports
}

_lookup_pkg_using_ports() {
  lookup_pkg_search_url="https://api.freshports.org/ports/v1/search/?search=$package_name&branch=head"

  lookup_pkg_search_result=$(curl -s "$lookup_pkg_search_url" 2>/dev/null)
  if [ $? -gt 0 ] || [ -z "$lookup_pkg_search_result" ] || printf '%s' "$lookup_pkg_search_result" | jq -e '.ports' >/dev/null 2>&1 && [ "$(printf '%s' "$lookup_pkg_search_result" | jq '.ports | length')" -eq 0 ]; then
    return 1
  fi

  lookup_pkg_exists=$(printf '%s' "$lookup_pkg_search_result" | jq -r ".ports[] | select(.name == \"$package_name\")" 2>/dev/null)
  [ -n "$lookup_pkg_exists" ]
}

_lookup_package_details() {
  package_url=https://www.freshports.org/$(printf '%s' "$lookup_pkg_exists" | jq -r '.category + "/" + .name')
  package_version=$(printf "$lookup_pkg_exists" | jq -r '.version')
}

_lookup_pkg_locally() {
  pkg search "^$package_name$" >/dev/null 2>&1
}

_lookup_pkg_info_locally() {
  [ -z "$DETAILS" ] && RETURN

  lookup_port_path=$(pkg info -g "$package_name*" 2>/dev/null | head -n1 | awk '{print $1}')
  if [ -n "$lookup_port_path" ]; then
    log_info "https://www.freshports.org/$(dirname "$lookup_port_path")"
    log_info $(pkg info -g "$package_name*" 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/[^)]*)//')
  fi
}
