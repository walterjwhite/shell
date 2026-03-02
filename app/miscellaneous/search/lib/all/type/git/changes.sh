search_git_changes() {
  if [ $# -eq 0 ]; then
    log_warn "not searching changes as no search argument was provided."
    return
  fi

  for _ARG in "$@"; do
    case $_ARG in
    -i)
      _options="${_options:+$_options }$_ARG"
      ;;
    *)
      if [ -n "$change_search" ]; then
        log_warn "excluding arg: $_ARG"
        continue
      fi

      _change_search=$(printf "$_ARG" | sed -e 's/^-/\\-/')
      ;;
    esac
  done

  if [ "$all_branches" ]; then
    _search_git_changes_all
    return
  fi

  _search_git_changes_do
}

_search_git_changes_do() {
  git log $branch -p $_options -G "$_change_search"
}

_search_git_changes_all() {
  for branch in $(git branch); do
    log_detail "searching changes in $branch"
    _search_git_changes_do
  done
}
