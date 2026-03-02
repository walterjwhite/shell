get_search_filenames_scope() {
  local search_scope=.
}

search_filenames_wd() {
  local search_filenames_path=.
  _search_filenames_do "$@"
}

search_filenames_all() {
  local search_filenames_path="$GIT_PROJECT_BASE_PATH $DATA_PATH"
  _search_filenames_do "$@"
}

search_filenames_system() {
  if [ ! -e $conf_search_locate_database ]; then
    log_warn "initializing locate database"
    $conf_search_locate_updatedb_cmd
  fi

  locate "$@"
}

_search_filenames_do() {
  [ "$edit" ] && _POST_ARGS="-exec $conf_search_editor {} +"
  [ "$xedit" ] && _POST_ARGS="-exec $conf_search_xeditor {} +"
  [ "$files" ] && _POST_ARGS="-execdir $conf_search_file_manager {} ;"

  set -o noglob

  for _ARG in "$@"; do
    case $_ARG in
    -i)
      local case_insensitive_search=i
      ;;
    -l) ;;
    *)
      local find_args="-${case_insensitive_search}path $_ARG"
      ;;
    esac
  done

  find $search_filenames_path \
    \( -type f -or -type l \) -and ! -path "$conf_search_exclude_path" \
    $find_args $_POST_ARGS
}
