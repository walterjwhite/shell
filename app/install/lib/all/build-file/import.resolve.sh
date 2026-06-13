_buildfile_import_process_single() {
  local type="$1"
  local ref="$2"
  local base_pattern=""
  local ref_type=""

  case "$ref" in
  feature:*)
    local feature_arg="${ref#*feature:}"

    local feature_name=$(printf '%s' "$buildfile_output_package_file" | $GNU_GREP -Po '[a-zA-Z0-9-]{3,}\.feature' | tail -1)
    local feature_path=$(find . -type d -name "$feature_name")

    if [ -z "$feature_path" ]; then
      log_warn "cannot resolve 'feature:' import. Target path does not contain '.feature': $buildfile_output_package_file | $ref"
      return 1
    fi

    local base_pattern="${feature_path}/${type}/%s/${feature_arg}"
    local ref_type=feature
    ;;
  .*)
    local base_pattern="${type}/%s/${ref}"

    local ref_type=relative
    ;;

  *)
    local base_pattern="${project_root}/${type}/%s/${ref}"


    [ -e "${APP_DATA_PATH}/sources" ] && {
      local lib_source shared_pattern
      for lib_source in $(find "${APP_DATA_PATH}/sources" -maxdepth 1 -mindepth 1 -type d); do
        if [ -n "$shared_pattern" ]; then
          shared_pattern="$shared_pattern $lib_source/${type}/__TARGET_PLATFORM__/${ref}"
        else
          shared_pattern="$lib_source/${type}/__TARGET_PLATFORM__/${ref}"
        fi
      done

      local path_platform_shared=$(printf '%s' "$shared_pattern" | sed -e "s/__TARGET_PLATFORM__/$target_platform/g")
      local path_all_shared=$(printf '%s' "$shared_pattern" | sed -e "s/__TARGET_PLATFORM__/all/g")
    }

    local ref_type=root

    ;;
  esac

  log_debug "base_pattern [$ref_type]: $base_pattern [$ref]"

  local path_platform path_all
  printf -v path_platform "$base_pattern" "$target_platform"
  printf -v path_all "$base_pattern" "all"

  if [ -z "$buildfile_optional" ]; then
    _buildfile_import_validate_paths "$path_platform" "$path_all" $path_platform_shared $path_all_shared || {
      log_warn "path does not resolve: $path_platform | $path_all | $path_platform_shared | $path_all_shared"
      return 1
    }
  fi

  log_debug "paths: $path_platform | $path_all"

  local found_file
  for found_file in $(find "$path_platform" "$path_all" $path_platform_shared $path_all_shared \
    \( -type f -or -type l \) \
    -and \( ! -name '*.test' ! -name '*_test.sh' \) \
    2>/dev/null | sort -u); do
    _buildfile_import_append_file "$found_file"
  done
}
