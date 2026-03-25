_scoop_install() {
  _scoop_get_buckets "$@" | _scoop_add_buckets
  scoop install "$@"
}

_scoop_update() {
  scoop update "$@"
}

_scoop_bootstrap() {
  exit_with_error "scoop bootstrap is not yet implemented"
}

_scoop_is_installed() {
  which scoop >/dev/null 2>&1
}

_scoop_add_buckets() {
  local scoop_bucket
  for scoop_bucket in $@; do
    _scoop_add_bucket $scoop_bucket
  done
}

_scoop_add_bucket() {
  scoop bucket list | $GNU_GREP -Pcqm1 "^${1}$" && {
    log_detail "$1 bucket already exists"
    return
  }

  log_warn "adding $1 bucket"
  scoop bucket add "$1"
}

_scoop_get_buckets() {
  printf '%s' "$*" | tr ' ' '\n' | cut -f1 -d/ | sort -u
}
