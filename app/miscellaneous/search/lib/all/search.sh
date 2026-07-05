_search_do() {
  search_function=$(printf '%s' "$search_type" | tr '/' '_' | tr '-' '_')
  search_super_type=$(printf '%s' "$search_type" | sed -e 's/\/.*$//')

  [ -z "$search_scope" ] && get_search_${search_super_type}_scope

  log_info "search ($search_scope | $(basename $PWD)): $*"
  search_scope_function=$(printf '%s' "$search_scope" | sed -e 's/\./wd/')
  exec_call search_${search_super_type}_${search_scope_function} "$@" || {
    [ $? -eq 127 ] && exit_with_error "invalid search type or search scope: ${search_super_type} | ${search_scope_function}"
  }
}
