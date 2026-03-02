search_git_changed_files() {
  if [ "$xedit" ]; then
    $conf_search_xeditor $(git status | sed 1d | awk {'print$2'})
  elif [ "$edit" ]; then
    $conf_search_xeditor $(git status | sed 1d | awk {'print$2'})
  else
    log_warn 'no action specified'
  fi
}
