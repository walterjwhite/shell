sudo_run() {





  log_warn "no op: $*"
}

sudo_is_validation_required() {



  log_warn "no op: $*"
}

_sudo_is_administrator() {
  net session >/dev/null 2>&1
}

sudo_ensure_administrator() {


  log_warn "no op: $*"
}

sudo_ensure_not_administrator() {

  log_warn "no op: $*"
}

sudo_ensure_root() {
  log_warn "no op: $*"
}

sudo_ensure_not_root() {
  log_warn "no op: $*"
}

sudo_precmd() {
  log_warn "no op: $*"
}
