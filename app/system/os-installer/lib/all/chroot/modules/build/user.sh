lib install/module/user.sh

patch_user() {
  user_bootstrap || {
    log_warn "exit_with_error bootstrapping user module"
    return 1
  }

  _module_find_callback _user_add
}

_user_add() {
  backup_ssh=1 _users_add $1
}
