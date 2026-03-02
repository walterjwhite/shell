_github_auth() {
  gh auth status >/dev/null || {
    log_info "logging into github"
    gh auth login

    return
  }

  log_detail "already logged into github"

  [ -z $git_username ] && git_username=$(secrets -out=stdout get $conf_github_username_key 2>/dev/null)

  validation_require "$git_username" "git_username - check secrets key: $conf_github_username_key"
}
