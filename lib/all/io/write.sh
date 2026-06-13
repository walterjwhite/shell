_write_append() {
  local _filename=$1
  sudo_run mkdir -p $(dirname $_filename)
  sudo_run tee -a "$_filename" >/dev/null
}

_write_write() {
  local _filename=$1
  sudo_run mkdir -p $(dirname $_filename)
  sudo_run tee "$_filename" >/dev/null
}

_write_conf_write() {
  local _conf_var=$1
  validation_require "$_conf_var" "$_conf_var - conf_* must not be empty"

  local _conf_name

  case $_conf_var in
  conf_*)
    _conf_name="${_conf_var#*conf_}"
    ;;
  optn_*)
    _conf_name="${_conf_var#*optn_}"
    ;;
  st_*)
    _conf_name="${_conf_var#*st_}"
    ;;
  *)
    exit_with_error "$_conf_var is not a conf (conf_), option (optn_), or state (st_)"
    ;;
  esac

  local _conf_file_name="${_conf_name%%_*}"
  local _conf_value=$(env | grep "$_conf_var" | sed -e 's/=.*//')

  [ -f $HOME/.config/walterjwhite/shell/$_conf_file_name ] && {
    grep -qm1 $_conf_var=.* $HOME/.config/walterjwhite/shell/$_conf_file_name && {
      log_warn "updating existing configuration: $_conf_var"
      $GNU_SED -i "s/$_conf_var=.*/$_conf_var=$_conf_value/" $HOME/.config/walterjwhite/shell/$_conf_file_name
      return
    }
  }

  log_detail "setting configuration: $_conf_var"
  printf '%s=%s\n' "$_conf_var" "$_conf_value" >>$HOME/.config/walterjwhite/shell/$_conf_file_name
}
