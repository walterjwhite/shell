_delete_delete_branches() {
  for _branch in $(_delete_delete_get_branches); do
    gco $_branch

    _delete_is_ahead && continue

    local _has_changes=$(gcs $delete_date | wc -l)
    if [ "$_has_changes" -eq "0" ]; then
      log_warn "delete $_branch - NO activity since $delete_date"

      [ -z "$optn_git_delete_old_branches_warn_only" ] && {
        [ -z "$git_local" ] && _delete_delete_remote_branch

        _delete_delete_local_branch
      }
    else
      log_debug "$_branch is active (since $delete_date), retaining (!delete)"
    fi
  done

  log_info "done archiving/deleting old branches - $PWD"
}

_delete_delete_get_branches() {
  local _git_options
  [ -z "$git_local" ] && {
    log_warn "deleting local AND remote branches"
    _git_options="-a"
  }

  gb $_git_options
}

_delete_delete_local_branch() {
  gco $(gb -a | grep -v "^${_branch}$" | head -1)
  gb -D $_branch 2>/dev/null
  [ $(git branch --list $_branch | wc -l) -eq 0 ] && {
    log_detail "deleted $_branch locally"
    repository_has_deleted_branches=1
  } || log_warn "unable to delete $_branch locally"
}

_delete_delete_remote_branch() {
  local _git_remote
  for _git_remote in $(git remote); do
    _delete_branch_exists_on_remote || {
      log_warn "$_branch does not exist on remote (origin)"
      continue
    }

    log_warn "deleting: $_branch"

    if [ $conf_git_delete_dryrun -gt 0 ]; then
      log_warn "dryrun: git push $_git_remote :$_branch"
      continue
    fi

    git push $_git_remote :$_branch || {
      log_warn "unable to delete branch on remote, aborting: $_branch"
      continue
    }

    repository_has_deleted_branches=1
  done
}

_delete_branch_exists_on_remote() {
  [ "$(git ls-remote --heads origin refs/heads/$_branch | wc -l)" -eq "0" ] && return 1

  return 0
}

_delete_create_backup_mirror() {
  _project_directory_get_project_directory

  local _repository_clone_file=$APP_DATA_PATH/$(basename $PWD)-$(date +$conf_git_backup_date_time_format).backup
  git clone --mirror $git_project_path $_repository_clone_file
}

_delete_is_ahead() {
  local _status=$(git status -sb)-
  local _ahead=$(printf '%s\n' "$_status" | $GNU_GREP -Pc "^##.{1,}\[ahead [\d]{1,}\]$")
  if [ "$_ahead" -gt "0" ]; then
    log_warn "$_branch is ahead: $_ahead"
    log_detail "$_status"

    return 0
  fi

  return 1
}
