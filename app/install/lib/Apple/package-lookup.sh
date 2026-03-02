_lookup_package() {
  for homebrew_package_type in formula cask; do
    _homebrew_lookup_do && return
  done
}

_homebrew_lookup_do() {
  lookup_search_result=$(curl -s "https://formulae.brew.sh/api/$homebrew_package_type/$package_name.json" 2>/dev/null)
  [ $? -ne 0 ] || [ -z "$lookup_search_result" ] || printf '%s' "$lookup_search_result" | grep -q "404"
}

_lookup_package_details() {
  package_url="https://formulae.brew.sh/$homebrew_package_type/$package_name"
  package_version=$(printf '%s' "$lookup_search_result" | jq -r '.versions.stable // .version // "unknown"' 2>/dev/null)
}
