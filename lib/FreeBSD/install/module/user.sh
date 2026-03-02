lib ssh.sh

user_bootstrap() {
  log_detail "bootstrapping user module"
  mkdir -p /root/.ssh/socket
  chmod -R 700 /root/.ssh/socket

  app-install configuration

  log_detail "bootstrapped user module"
}

_user_install() {
  _user_users_add "$1"
}

user_uninstall() {
  local _filename=$1
  . "$_filename"

  validation_require "$username" "username"
  rmuser -y "$username"
}

_user_is_installed() {
  return 1
}

_user_enabled() {
  return 0
}

_user_users_add_argument() {
  local _option=$1
  local _value=$2

  [ -n "$_value" ] && user_options="$user_options $_option $_value"
}

_user_users_add() {
  local _config_file=$1
  local user_options _username _gid _grouplist _shell _uid _password _system

  . "$_config_file"

  if [ "$_username" != "root" ]; then
    pw user show "$_username" >/dev/null 2>&1 || {
      log_info "add user: $_username"

      user_options="-n $_username -m"

      _user_users_add_argument "-g" "$_gid"
      _user_users_add_argument "-G" "$_grouplist"
      _user_users_add_argument "-s" "$_shell"
      _user_users_add_argument "-u" "$_uid"

      pw useradd $user_options
    }
  else
    [ -n "$_shell" ] && {
      log_info "setting shell to $_shell for root"
      chsh -s "$_shell"
    }
  fi

  if [ -n "$_password" ]; then
    log_info "setting password for $_username"
    chpass -p "$_password" "$_username"
  fi

  _user_configure
}

_user_users_get_data() {
  printf '%s\n' "$_username" | tr ' ' '\n'
}

_user_configure() {
  local _user_home
  _user_home=$(grep "^$_username:" /etc/passwd | cut -f6 -d':')

  _ssh_prepare_ssh_conf "$_user_home" "$_username"

  local _original_pwd=$PWD
  cd /tmp

  if [ -n "$_system" ]; then
    log_warn "$_username is a system user, bypassing configuration"
  else
    warn_on_error=1 _SUDO_USER=$username log_logfile=$log_logfile sudo_options="--preserve-env=conf_git_mirror,backup_ssh,http_proxy,https_proxy,_SUDO_USER,warn_on_error,log_logfile -H" exec_wrap sudo_run conf restore || _user_configure_debug
  fi
  [ "$_username" != "root" ] && {
    chown -R "$_username:$_username" "$_user_home"
  }

  cd "$_original_pwd"
}

_user_configure_debug() {
  local _user_home
  _user_home=$(grep "^$_username:" /etc/passwd | cut -f6 -d':')

  log_warn "error restoring configuration for $_username"
  cat "$_user_home/.ssh/id_*.pub"
  cat "$_user_home/.ssh/authorized_keys"
  cat "$_user_home/.ssh/config"
}
