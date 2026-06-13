search_git_logs() {
  if [ $# -eq 0 ]; then
    log_warn "not searching logs as no search argument was provided."
    return
  fi

  for _ARG in "$@"; do
    case $_ARG in
    -i)
      local options="${options:+$options }$_ARG"
      ;;
    *)
      if [ -n "$logs_search" ]; then
        log_warn "excluding arg: $_ARG"
        continue
      fi

      local logs_search="$_ARG"
      ;;
    esac
  done

  if [ "$all_branches" ]; then
    _search_git_logs_all
    return
  fi

  _search_git_logs_do
}

_search_git_logs_do() {
  git log $branch $options --grep="$logs_search"
}

_search_git_logs_all() {
  for branch in $(git branch); do
    log_detail "searching logs in $branch"
    _search_logs_do
  done
}
