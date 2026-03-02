lib extract.sh

_git_zip_install_app_registry() {
  log_detail "installing from app.registry zip: $target_application_name"

  [ -z "$git_zip_app_registry_extracted" ] && {
    rm -rf $REGISTRY_PATH && mkdir -p $REGISTRY_PATH

    local temp_dir=$(_mktemp_options=d _mktemp_mktemp)
    local zip_file="${target_application_name%%:*}"
    _extract_extract $zip_file $temp_dir || exit_with_error "error extracting zip"

    cd $temp_dir
    cd $(ls -1 | head -1)

    mv * $REGISTRY_PATH
    local git_zip_app_registry_extracted=1

    cd $REGISTRY_PATH
    rm -rf $temp_dir
  }

  local git_target_application_url=$target_application_name

  target_application_name=${target_application_name#*:}

  _git_app_dir_setup
}
