_buildfile_import_append_file() {
  local src="$1"

  case "$buildfile_imported_files" in
  *"|$src|"*)
    log_debug "skipping duplicate: $src"
    return 0
    ;;
  esac

  if [ -e "${src}.test" ]; then
    if ! (. "${src}.test" "$buildfile_output_package_file"); then
      log_debug "skipping $src (test failed) | $buildfile_output_package_file"
      return 0
    fi
  fi

  buildfile_imported_files="${buildfile_imported_files}|$src|"

  log_debug "importing $src"
  cat "$src" >>"$buildfile_output_package_file"
}
