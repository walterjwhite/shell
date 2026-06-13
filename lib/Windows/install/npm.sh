npm_bootstrap_platform() {
  prefix=$(npm config get prefix 2>/dev/null)

  if [ -z "$prefix" ] || [ "$prefix" = "undefined" ]; then
    log_warn "unable to determine npm prefix"
    return 1
  fi

  if [ -d "$prefix/bin" ]; then
    npm_bin="$prefix/bin"
  else
    npm_bin="$prefix"
  fi

  case ":$PATH:" in
  *:"$npm_bin":*)
    log_warn "npm bin already in PATH: $npm_bin"
    ;;
  *)
    PATH="$PATH:$npm_bin"
    export PATH

    printf '%s' "$PATH:$npm_bin" | tr -d '\n' | setx Path -Force >/dev/null

    log_info "updated PATH to include npm_bin"
    ;;
  esac
}
