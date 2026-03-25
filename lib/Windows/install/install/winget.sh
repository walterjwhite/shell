_winget_install() {
  if printf '%s\n' "$@" | grep -q '\.'; then
    winget install --id "$@" -e
    return
  fi

  winget install "$@"
}

_winget_update() {
  if [ "$#" -eq 0 ]; then
    winget upgrade --all
    return
  fi

  if printf '%s\n' "$@" | grep -q '\.'; then
    winget upgrade --id "$@" -e
  else
    winget upgrade "$@"
  fi
}


_winget_bootstrap() {
  _winget_is_installed || {
    log_warn "winget cmd not found, disabling"
    winget_disabled=1
    return 1
  }

  return 0
}

_winget_is_installed() {
  command -v winget >/dev/null 2>&1
}
