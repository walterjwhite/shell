_app_build_init_artifact_dir() {
  local target_dir="$ARTIFACTS_PATH/$target_application_name/$target_platform"

  validation_require "$target_dir" target_dir

  rm -rf "$target_dir"
  mkdir -p "$target_dir"
}

_app_build_package_files() {
  export project_root target_application_name
  export target_application_version target_platform target_sub_platform

  _scan_and_build cfg
  _scan_and_build lib
  _scan_and_build init

  _scan_and_build setup cfg lib init
  _scan_and_build post-setup cfg lib init
}

_scan_and_build() {
  for platform in all $APP_PLATFORM_PLATFORM; do
    _find_files_in "$@" | _filter_files "$@" | _app_build_run || {
      exit_with_error "see above output for errors" $?
    }
  done
}

_app_build_run() {
  [ "$conf_log_level" -eq 0 ] && sequential_build=1

  if [ -n "$sequential_build" ]; then
    log_warn "running sequential build process for log_debug purposes"
    local build_filename
    while read -r build_filename; do
      [ -z "$build_filename" ] && continue

      _app_build_package_file "$build_filename" || exit_with_error "failed to build $build_filename"
    done
  else
    export logging_context

    xargs -r -P"$conf_install_max_concurrent_jobs" -I % \
      "$APP_LIBRARY_PATH/bin/_build-file" % || exit_with_error "failed to build files"
  fi
}

_find_files_in() {
  local include_path=$1
  shift

  find . -type f \
    \( ! -path '*.secret*' ! -path '*.archived*' ! -path '*/.git/*' ! -path '*/.github/*' ! -name '*_test.sh' \) \
    -a \( -path "*/$include_path/$platform/*" \)

  unset include_path
}
