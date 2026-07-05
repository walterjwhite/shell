lib io/file.sh

_crontab_clear() {
  validation_require "$1" "Crontab User"
  crontab_${conf_cron_provider}_clear "$@"
}

_crontab_get() {
  validation_require "$1" "Crontab User"
  validation_require "$2" "Crontab Filename to write to"

  crontab_${conf_cron_provider}_get "$@"
}

_crontab_write() {
  validation_require "$1" "Crontab User"
  file_require "$2" "Crontab File"

  crontab_${conf_cron_provider}_write "$@"
}

_crontab_append() {
  validation_require "$1" "Crontab User"
  file_require "$2" "Crontab File"

  _file_has_contents $2 || return 1

  local current_crontab=$(_mktemp_mktemp)
  [ "$1" = "root" ] && chown $1: $current_crontab

  _crontab_get $1 $current_crontab

  _crontab_run "$1" sh -c 'cat "$1" >> "$2"' _ "$2" "$current_crontab"
  crontab_${conf_cron_provider}_write "$1" "$current_crontab"
  _crontab_run "$1" rm -f "$current_crontab"
}

crontab_default_clear() {
  _crontab_run "$1" crontab -r 2>/dev/null
}

crontab_default_get() {
  _crontab_run "$1" sh -c 'crontab -l > "$1" 2>/dev/null || true' _ "$2"
}


crontab_default_write() {
  _crontab_default_header "$1" "$2"

  _crontab_run "$1" crontab "$2" || {
    log_warn "error writing crontab"
    _crontab_run "$1" cat "$2"
  }
}

_crontab_default_header() {
  [ ! -e "$2" ] && {
    log_warn "crontab file $2 does not exist"
    return 1
  }

  [ -z "$crontab_header" ] && return 0

  local _header="$crontab_header"
  _crontab_run "$1" sh -c 'printf "%s\n\n" "$1" > "$2.new"' _ "$_header" "$2"
  _crontab_run "$1" sh -c 'cat "$1" >> "$1.new" && mv "$1.new" "$1"' _ "$2"
}

_crontab_run() {
  local _user="$1"
  shift
  if [ "$_user" = "root" ]; then
    sudo_user=root sudo_run "$@"
  else
    "$@"
  fi
}
