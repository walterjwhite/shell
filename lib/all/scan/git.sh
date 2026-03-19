_scan_git_init() {
  opwd=$PWD
  _data_app_init

  data_app_git_project_path=$git_project_path

  git_project_relative_path=$(printf '%s' $opwd | sed -e "s|$GIT_PROJECT_BASE_PATH/||")

  local scan_extension
  [ -n "$scan_file_extension" ] && scan_extension=".$scan_file_extension"

  report_path=$APP_DATA_PATH/$scan_type/$git_project_relative_path/$(gcb)$scan_extension
  mkdir -p $(dirname $report_path)

  report_scan_commit_path=$APP_DATA_PATH/$scan_type/$git_project_relative_path/$(gcb).commit
  cd $opwd

  _scan_has_changes || return 1

  _project_directory_get_project_directory || exit_with_error "not in a git workspace"

  cd $git_project_path
}

_scan_has_changes() {
  scan_current_commit=$(git rev-parse --short HEAD)

  [ ! -f "$report_scan_commit_path" ] && return 0

  local scan_last_commit=$(head -1 $report_scan_commit_path)
  log_debug "last commit: $scan_last_commit"

  [ "$scan_last_commit" == "$scan_current_commit" ] && {
    log_warn 'no git activity since last scan, aborting'
    return 1
  }

  return 0
}

_scan_run() {
  scan_type=$1
  shift

  if [ -n "$1" ]; then
    scan_file_extension=$1
    shift
  fi

  _scan_git_init || {
    log_warn "no changes since last run"
    return 0
  }

  if [ ! -e $report_path ]; then
    log_info "no existing scan found"
    _scan_new
  else
    log_info "performing a delta scan"
    _scan_delta
  fi

  _scan_git_write
}

_scan_git_write() {
  cd $data_app_git_project_path

  printf '%s\n' "$scan_current_commit" >$report_scan_commit_path

  git add $scan_type
  git commit $scan_type -m "$scan_type"
  git push
}
