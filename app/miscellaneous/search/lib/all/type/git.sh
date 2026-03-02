lib io/path.sh

get_search_git_scope() {
  warn_on_error=1 _project_directory_get_project_directory && {
    search_scope=.
    return
  }

  _path_in_path "$GIT_PROJECT_BASE_PATH" && {
    search_scope=recursive
    return
  }

  _path_in_path "$DATA_PATH" && {
    search_scope=recursive
    return
  }

  search_scope=all
}

search_git_wd() {
  [ $conf_search_cwd_only -eq 0 ] && unset git_no_init_project_directory

  [ $search_recursive ] || log_detail "searching $search_function @ $_PROJECT: $*"
  search_${search_function} "$@"
}

search_git_recursive() {
  conf_install_no_pager=$conf_search_recursive_pager

  search_recursive=1
  [ -z "$search_path" ] && search_path=.

  search_scope=. find $search_path \( -type d -or -type f \) -name '.git' -execdir search "$@" \;
}

search_git_all() {
  if [ -z "$GIT_PROJECT_BASE_PATH" ] && [ -z "$DATA_PATH" ]; then
    search_path="."
  else
    search_path="$GIT_PROJECT_BASE_PATH $DATA_PATH"
  fi

  search_git_recursive "$@"
}
