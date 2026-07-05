configuration_clear() {
  :
}

configuration_clear_default() {
  rm -rf "$provider_path"

  [ -z "$provider_include" ] && return

  [ -n "$provider_path_is_dir" ] && return

  local parent=$(dirname "$provider_path")
  local file
  for file in $provider_include; do
    rm -f $parent/$file
  done
}

configuration_clear_sync() {
  :
}

