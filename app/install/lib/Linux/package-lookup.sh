_lookup_package() {
  _extract_category_and_package

  local result

  if [ -n "$package_category" ]; then
    lookup_search_result=$(curl -s "https://packages.gentoo.org/packages/$package_category/$package_name" 2>/dev/null)
    printf '%s' "$lookup_search_result" | grep -q "kk-package-title"
    return
  fi

  lookup_search_result=$(curl -s "https://packages.gentoo.org/packages/search?q=$package_name" 2>/dev/null)
  _lookup_package_has_results || return 1

  printf '%s' "$lookup_search_result" | grep -q "<span class=\"text-muted\">$package_name/</span>" && return 0
  printf '%s' "$lookup_search_result" | grep -q "href=\"/packages/$package_name\"" && return 0
  printf '%s' "$package_name" | grep -q "/" && printf '%s' "$lookup_search_result" | grep -q "href=\"/packages/$package_name\"" && return 0

  printf '%s' "$lookup_search_result" | grep -q "list-group-item-action" || return 1

  printf '%s' "$lookup_search_result" | grep -q ">[^<]*$package_name[^<]*</h3>" && return 0

  return 1
}

_lookup_package_has_results() {
  printf '%s' "$lookup_search_result" | grep -q "Results 1—0 of 0" && return 1

  printf '%s' "$lookup_search_result" | grep -q "Error 404" && return 1

  return 0
}

_lookup_package_details() {
  local package_version=$(printf '%s' "$lookup_search_result" | grep -o 'class="kk-ebuild-link"[^>]*>[^<]*[0-9][^<]*<' | sed 's/.*>\([^<]*\)<.*/\1/' | head -n1)
  if [ -z "$package_version" ]; then
    package_version=$(printf '%s' "$lookup_search_result" | grep -o 'href="[^"]*-[0-9][^"]*\.ebuild"[^>]*>[^<]*[0-9][^<]*<' | sed 's/.*>\([^<]*\)<.*/\1/' | head -n1)
  fi
  if [ -z "$package_version" ]; then
    package_version="unknown"
  fi

  package_url="https://packages.gentoo.org/packages/$package_name"
}

lookup_local_emerge_package() {
  equery list "$package_name" >/dev/null 2>&1
}

lookup_local_emerge_package_details() {
  local package_version=$(equery list -p "$package_name" 2>/dev/null | head -n1 | awk '{print $2}')
  if [ -z "$package_version" ]; then
    package_version=$(equery list "$package_name" 2>/dev/null | head -n1 | awk '{print $1}' | sed 's/.*-\([^-]*-r[0-9]*\)$/\1/')
  fi
  if [ -z "$package_version" ]; then
    package_version="unknown"
  fi

  log_info "https://packages.gentoo.org/packages/$package_category/$package_name"
  log_info "$package_version"
}

_extract_category_and_package() {
  if printf '%s' "$package_name" | grep -q "/"; then
    package_category=$(printf '%s' "$package_name" | cut -d'/' -f1)
    package_name=$(printf '%s' "$package_name" | cut -d'/' -f2)
  fi
}
