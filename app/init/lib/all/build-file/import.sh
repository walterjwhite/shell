_buildfile_imports() {
  local type="$1"
  local source_file="$2"
  local default_imports="$3"

  buildfile_imported_files=""
  buildfile_raw_imports=$(_buildfile_imports_get_for_file $source_file)
  if [ -n "$default_imports" ]; then
    buildfile_raw_imports="$default_imports
                $buildfile_raw_imports"
  fi

  log_debug "initial imports: $buildfile_raw_imports"

  local iteration=0
  while [ $iteration -lt 10 ]; do
    iteration=$((iteration + 1))
    [ -z "$buildfile_raw_imports" ] && break

    [ -n "$before_function" ] && exec_call "$before_function"

    local raw_import
    for raw_import in $buildfile_raw_imports; do
      _buildfile_import_process_single "$type" "$raw_import"
    done

    buildfile_raw_imports=$(_buildfile_imports_get_for_file $buildfile_output_package_file)
  done

  unset buildfile_imported_files
}

_buildfile_imports_get_for_file() {
  $GNU_GREP -P "^$type " "$1" | sed -e "s/^$type //" | sort -u

  $GNU_SED -i "/^$type .*/d" "$buildfile_output_package_file"
}
