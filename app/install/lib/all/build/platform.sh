_app_build_determine_build_platforms() {
  [ -n "$build_platforms" ] && return

  if [ -z "$build_all_platforms" ]; then
    build_platforms=$platforms
    return
  fi

  [ -e supported-platforms ] && {
    build_platforms=$(cat supported-platforms)
    return
  }

  build_platforms=$APP_PLATFORM_SUPPORTED_PLATFORMS

  [ -z "$build_platforms" ] && build_platforms=$platforms
}

_app_build_platforms() {
  for target_platform in $build_platforms; do
    log_add_context $target_platform

    _app_build_platform_name
    _app_build_init_artifact_dir

    printf '\n'

    log_info "building"

    _app_build_package_files
    log_remove_context
  done
}

_app_build_platform_name() {
  case $target_platform in
  */*)
    target_sub_platform=${target_platform#*/}
    target_platform=${target_platform%%/*}
    ;;
  *) ;;
  esac
}
