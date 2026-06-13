search_git_contents() {
  if [ $# -eq 0 ]; then
    log_warn "not searching contents as no search argument was provided."
    return
  fi

  for _ARG in "$@"; do
    case $_ARG in
    --before=*)
      shift
      ;;
    --after=*)
      shift
      ;;
    -i | -v | -l)
      _options="${_options:+$_options }$_ARG"
      shift
      ;;
    *)
      break
      ;;
    esac
  done

  for _ARG in "$@"; do
    case $_ARG in
    *)
      if [ -n "$contents_search" ]; then
        log_warn "excluding arg: $_ARG"
        continue
      fi

      local contents_search=$(printf "$_ARG" | sed -e 's/^-/\\-/')
      ;;
    esac
  done

  : ${search_commits:=current}
  _search_git_contents_get_type

  if [ $conf_search_contents_recurse_submodules -eq 1 ]; then
    _options="${_options:+$_options }--recurse-submodules"
  fi

  if [ "$xedit" ]; then
    _git_contents_xedit
  elif [ "$edit" ]; then
    _git_contents_edit
  elif [ "$files" ]; then
    _git_contents_files
  else
    _git_contents_search
  fi
}

_git_contents_search() {
  _options="${_options:+$_options }-n"
  git_contents_search_$search_commits
}

git_contents_search_current() {
  [ "$include_hidden" ] && {
    log_warn 'including hidden files'
    git grep -I $_options "$contents_search" $branch
    return
  }

  git grep -I $_options "$contents_search" $branch -- ":(exclude)*.secret*" ":(exclude)*.archived*"
}

git_contents_search_any() {
  git rev-list --all | xargs git_contents_search_current
}

git_contents_search_all() {
  for branch in $(git branch); do
    log_detail "searching contents in $branch"
    git_contents_search_current
  done
}

_git_contents_edit() {
  _options="${_options:+$_options }-l"
  $conf_search_editor $(git_contents_search_current)
}

_git_contents_xedit() {
  _options="${_options:+$_options }-l"
  $conf_search_xeditor $(git_contents_search_current)
}

_git_contents_files() {
  _options="${_options:+$_options }-l"
  $conf_search_file_manager $(dirname $(git_contents_search_current) | sort -u)
}

_search_git_contents_get_type() {
  case $conf_search_contents_type in
  string)
    _options="${_options:+$_options }-F"
    ;;
  regex)
    _options="${_options:+$_options }-G"
    ;;
  *)
    exit_with_error "unknown search type: $conf_search_contents_type"
    ;;
  esac
}
