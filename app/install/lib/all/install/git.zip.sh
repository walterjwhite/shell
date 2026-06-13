lib extract.sh

_git_zip_install_app_registry() {
  log_detail "installing from app.registry zip: $target_application_name"

  [ -z "$git_zip_app_registry_extracted" ] && {
    rm -rf "$registry_path" && mkdir -p "$registry_path"

    local temp_dir
    temp_dir=$(_mktemp_options=d _mktemp_mktemp)
    local zip_file="${target_application_name%%:*}"
    _extract_extract "$zip_file" "$temp_dir" || exit_with_error "error extracting zip"

    cd "$temp_dir" || exit_with_error "cannot cd to temp dir: $temp_dir"

    local extracted_count
    extracted_count=$(ls -1 | wc -l)
    [ "$extracted_count" -ne 1 ] && exit_with_error "expected 1 top-level directory in zip, found $extracted_count"

    local extracted_dir
    extracted_dir=$(ls -1 | head -1)
    cd "$extracted_dir" || exit_with_error "cannot cd to extracted directory: $extracted_dir"

    mv -- * "$registry_path"
    local git_zip_app_registry_extracted=1

    cd "$registry_path" || exit_with_error "cannot cd to registry path: $registry_path"
    rm -rf "$temp_dir"
  }

  local git_target_application_url=$target_application_name

  target_application_name=${target_application_name#*:}

  _git_app_dir_setup
}
