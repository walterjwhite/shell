_app_build_determine_build_platforms() {
  supported_build_platforms=$APP_PLATFORM_SUPPORTED_PLATFORMS
  [ -e supported-platforms ] && {
    supported_build_platforms=$(cat supported-platforms)
  }

  [ -n "$build_platforms" ] && {
    local supported_build_platforms_grep=$(printf '%s\n' "$supported_build_platforms" | tr '\n' '|' | sed -e 's/|$//')
    build_platforms=$(printf '%s\n' $build_platforms | $GNU_GREP -Po "($supported_build_platforms_grep)")
    return
  }

  if [ -z "$build_all_platforms" ]; then
    build_platforms=$APP_PLATFORM_PLATFORM
    return
  fi

  build_platforms="$supported_build_platforms"


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
