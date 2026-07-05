lib io/path.sh

_git_workspace_ticket_id() {
  git_ticket_id=

  [ -n "$_CONSOLE_CONTEXT_ID" ] && {
    git_ticket_id=$_CONSOLE_CONTEXT_ID
    return 0
  }

  [ -n "$APP_CONTEXT" ] && [ "$APP_CONTEXT" != default ] && {
    git_ticket_id=$APP_CONTEXT
    return 0
  }

  return 1
}

_git_workspace_repos_path() {
  _git_workspace_ticket_id || return 1

  git_workspace_repos_path=$GIT_WORKSPACE_BASE_PATH/$git_ticket_id/repos
}

_git_workspace_project_full_path() {
  local project_relative_path=$1

  _git_workspace_repos_path || return 1

  project_full_path=$git_workspace_repos_path/$project_relative_path
}

_git_in_workspace_path() {
  _path_in_path $GIT_WORKSPACE_BASE_PATH
}

_git_workspace_checkout_ticket_branch() {
  _git_workspace_ticket_id || return 1
  validation_require "$project_full_path" project_full_path
  validation_require "$conf_git_workspace_base_branch" conf_git_workspace_base_branch

  local opwd=$PWD

  cd "$project_full_path" || return 1

  if git show-ref --verify --quiet refs/heads/$git_ticket_id; then
    git checkout $git_ticket_id
    cd $opwd
    return 0
  fi

  git fetch origin 2>/dev/null

  if git show-ref --verify --quiet refs/remotes/origin/$conf_git_workspace_base_branch; then
    git checkout -b $git_ticket_id origin/$conf_git_workspace_base_branch
  elif git show-ref --verify --quiet refs/heads/$conf_git_workspace_base_branch; then
    git checkout -b $git_ticket_id $conf_git_workspace_base_branch
  else
    log_warn "base branch $conf_git_workspace_base_branch not found, creating $git_ticket_id from current HEAD"
    git checkout -b $git_ticket_id
  fi

  cd $opwd
}
