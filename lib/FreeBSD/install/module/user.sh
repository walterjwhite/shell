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
  rmuser -y $username
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
}

_users_add() {
  . $1

  log_add_context $username

  if [ "$username" != "root" ]; then
    pw user show "$username" >/dev/null 2>&1 || {
      log_info "add user: $username"

      user_options="-n $username -m"

      _users_add_argument "-g" "$gid"
      _users_add_argument "-G" "$grouplist"
      _users_add_argument "-s" "$shell"
      _users_add_argument "-u" "$uid"

      pw useradd $user_options
    }
  else
    [ -n "$shell" ] && {
      log_info "setting shell to $shell"
      chsh -s "$shell"
    }
  fi

  if [ -n "$password" ]; then
    log_info "setting password for $username"
    chpass -p "$password" "$username"
  fi

  _users_configure
  unset user_options username gid grouplist shell uid password system
  log_remove_context
}

_users_get_data() {
  printf '%s\n' "$1" | tr ' ' '\n'
}

_users_configure() {
  _user_home=$(grep "^$username:" /etc/passwd | cut -f6 -d':')
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
    export optn_git_mirror=$optn_git_mirror
    export http_proxy="$http_proxy"
    export https_proxy="$https_proxy"
    export sudo_user=$username
    export warn_on_error=1
    export HOME=$_user_home
    export sudo_options="--preserve-env=optn_git_mirror,backup_ssh,http_proxy,https_proxy,sudo_user,warn_on_error,HOME -H"

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
