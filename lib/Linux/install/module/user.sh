lib ssh.sh

user_bootstrap() {
  log_detail "bootstrapping user module"
  mkdir -p /root/.ssh/socket
  chmod -R 700 /root/.ssh/socket

  app-install configuration

  log_detail "bootstrapped user module"
}

user_install() {
  _users_add "$1"
}

user_uninstall() {
  . "$1"

  validation_require "$username" "username"
  userdel $username
}

_user_is_installed() {
  :
}

_user_enabled() {
  return 0
}

_users_add_argument() {
  local _option=$1
  local _value=$2
  [ -n "$_value" ] && user_options="$user_options $_option $_value"
  unset _option _value
}

_users_add() {
  . $1

  log_add_context $username

  if [ "$username" != "root" ]; then
    getent passwd $username >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      log_info "user already exists"

      [ -n "$home" ] && {
        log_info "setting user home: $home"
        usermod -m -d $home $username
      }
    else
      log_info "add user: $1: $username"

      user_options="-m"

      _users_add_argument "-g" "$gid"
      _users_add_argument "-G" "$grouplist"
      _users_add_argument "-s" "$shell"
      _users_add_argument "-u" "$uid"
      _users_add_argument "-p" "$password"

      useradd $user_options $username
    fi
  else
    [ -n "$shell" ] && {
      log_info "setting shell to $shell"
      chsh -s "$shell"
    }

    if [ -n "$password" ]; then
      log_info "setting password"
      usermod -p "$_password" $username
    fi
  fi

  _users_configure
  unset user_options username _gid _grouplist _shell _uid _password _system
  log_remove_context
}

_users_get_data() {
  printf '%s\n' "$1" | tr ' ' '\n'
}

_users_configure() {
  _user_home=$(getent passwd $username | cut -d: -f6)
  [ -z "$_user_home" ] || [ "$_user_home" = "/" ] && {
    log_warn "user home is unset"
    return 1
  }

  _ssh_prepare_ssh_conf $_user_home $username

  local _original_pwd=$PWD
  cd /tmp

  if [ -n "$system" ]; then
    log_warn "$username is a system user, bypassing configuration"
  else
    local ohome=$HOME

    export backup_ssh=1
    export conf_git_mirror=$conf_git_mirror
    export http_proxy="$http_proxy"
    export https_proxy="$https_proxy"
    export sudo_user=$username
    export warn_on_error=1
    export HOME=$_user_home
    export sudo_options="--preserve-env=conf_git_mirror,backup_ssh,http_proxy,https_proxy,sudo_user,warn_on_error,HOME -H"

    exec_wrap sudo_run conf restore || _user_configure_debug

    HOME=$ohome
  fi

  [ "$username" != "root" ] && {
    chown -R $username:$username $_user_home
  }

  cd $_original_pwd
  unset _user_home _original_pwd
}

_user_configure_debug() {
  log_warn "error restoring configuration for $username"
  cat $_user_home/.ssh/id_*.pub
  cat $_user_home/.ssh/authorized_keys
  cat $_user_home/.ssh/config
}
