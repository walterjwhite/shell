_lookup_package() {
  lookup_chocolatey_search_url="https://community.chocolatey.org/api/v2/Search()?$filter=IsLatestVersion&searchTerm=$package_name"
  lookup_search_result=$(curl -s "$lookup_chocolatey_search_url" 2>/dev/null)

  if [ $? -ne 0 ] || [ -z "$lookup_search_result" ] || echo "$lookup_search_result" | grep -q "error"; then
    return 1
  fi
}

_lookup_package_details() {
  printf '%s' "$lookup_search_result" | grep -q "<title>$package_name" && return

  package_version=$(echo "$lookup_search_result" | sed -n "/<title>$package_name/s/.*<title>$package_name \([^<]*\)<\/title>.*/\1/p" | head -n1)
  if [ -z "$package_version" ]; then
    package_version=$(echo "$lookup_search_result" | sed -n "/<title>$package_name/s/.*<d:Version>\(.*\)<\/d:Version>.*/\1/p" | head -n1)
  fi
  if [ -z "$package_version" ]; then
    package_version="unknown"
  fi

  package_url="https://community.chocolatey.org/packages/$package_name"
}

_lookup_locally() {
  if command -v choco >/dev/null 2>&1; then
    if choco search "^$package_name$" --local-only >/dev/null 2>&1; then
      if [ -n "$additional_flags" ] && echo "$additional_flags" | grep -q "\-details"; then
        local details version
        details=$(choco search "$package_name" --detail --limit-output 2>/dev/null | head -n1)
        if [ -n "$details" ]; then
          version=$(echo "$details" | cut -d'|' -f2)
          echo "https://community.chocolatey.org/packages/$package_name"
          echo "$version"
        fi
      fi
      exit 0
    fi
  fi

  echo "package not found" >&2
  exit 1
}
