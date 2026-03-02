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
  chown $1: $current_crontab

  _crontab_get $1 $current_crontab

  sudo_run cat $2 | sudo_run tee -a $current_crontab >/dev/null 2>&1
  crontab_${conf_cron_provider}_write $1 $current_crontab
  sudo_run rm -f $current_crontab
}

crontab_default_clear() {
  sudo_user=$1 sudo_run crontab -f -r 2>/dev/null
}

crontab_default_get() {
  sudo_user=$1 sudo_run crontab -l >$2 2>/dev/null
}


crontab_default_write() {
  _crontab_default_header $1 $2

  sudo_user=$1 sudo_run crontab $2 || {
    log_warn "exit_with_error writing crontab"
    sudo_user=$1 sudo_run cat $2
  }
}

_crontab_default_header() {
  [ ! -e $2 ] && {
    log_warn "crontab file $2 does not exist"
    return 1
  }


  if [ -n "$optn_install_crontab_header" ]; then
    printf '%s\n\n' "$optn_install_crontab_header" | sudo_user=$1 sudo_run tee -a $2.new >/dev/null 2>&1
    sudo_user=$1 sudo_run cat $2 | sudo_user=$1 sudo_run tee -a $2.new >/dev/null 2>&1
    sudo_user=$1 sudo_run mv $2.new $2
  fi


  sudo_user=$1 sudo_run cat $2 | sudo_user=$1 sudo_run tee -a $2.new >/dev/null 2>&1
  sudo_user=$1 sudo_run mv $2.new $2
}
