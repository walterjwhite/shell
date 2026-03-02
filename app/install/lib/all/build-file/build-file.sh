_app_build_package_file() {
  log_detail "$1"

  _app_build_package_file_supports_platform $1 || {
    log_warn "not building $1 as it does not support $target_platform"
    return 1
  }

  buildfile_relative_package_file=$(printf '%s\n' "$1" | sed -e "s/\/$target_platform\//\//g" -e 's/\/all\//\//g' -e 's/.none$//' -e 's/.lite$//')
  buildfile_output_package_file=$ARTIFACTS_PATH/$target_application_name/$target_platform/$buildfile_relative_package_file

  mkdir -p $(dirname $buildfile_output_package_file)

  _app_build_inject $1

  _buildfile_update_remove_commented_code
  _app_build_validate

  _buildfile_update_constants

  _app_build_correct_permissions $1

  log_debug "built $1 -> [$target_platform] [$APP_PLATFORM_PLATFORM]"

  if [ -z "$run_preserve_build_vars" ]; then
    unset buildfile_relative_package_file buildfile_output_package_file
  fi
}

_app_build_validate() {
  case $buildfile_output_package_file in
  */setup/files/*)
    case $buildfile_output_package_file in
    */setup/files/_ROOT_/etc/systemd/* | */setup/files/_ROOT_/lib/systemd/* | */setup/files/_ROOT_/etc/init.d/*)
      log_warn "skipping validation for: $buildfile_output_package_file"
      return
      ;;
    */setup/files/_APPLICATION_ROOT_/* | */setup/files/_ROOT_/*) ;;
    *)
      log_warn "skipping validation for: $buildfile_output_package_file"
      return
      ;;
    esac
    ;;
  esac

  _buildfile_constants_has_invalid
  _buildfile_mixed_case_names_has_invalid
  _buildfile_local_var_names_has_invalid
  _buildfile_invalid_functions_has_invalid_name
  _buildfile_required_arguments_case_has_invalid
  _buildfile_log_messages_start_lowercase
  _buildfile_forbidden_exit_calls_has_invalid

  validation_required_cfg

  _buildfile_invalid_filenames_is_valid
  _buildfile_duplicate_functions_find
  _buildfile_missing_trailing_newline_check
}

_app_build_inject() {
  case $1 in
  */extensions/*/bin/*)
    _buildfile_inject_extension_cmd $1
    ;;
  *.none)
    _buildfile_inject_none $1
    ;;
  */bin/*)
    _buildfile_inject_full $1
    ;;
  lib/* | */lib/* | init/* | */init/* | */extensions/*/extension/* | */extensions/*/type/* | */files/*.sh | *.lite | *run)
    _buildfile_inject_lite $1
    ;;
  *)
    _buildfile_inject_none $1
    ;;
  esac
}

_app_build_package_file_supports_platform() {
  case "$1" in
  */feature/*.feature/*) ;;
  *)
    return 0
    ;;
  esac

  _app_build_check_supported_platforms $(dirname "$1" | $GNU_GREP -Po '.*feature/.*\.feature')
}

_app_build_check_supported_platforms() {
  local feature_dir="$1"

  while [ -n "$feature_dir" ]; do
    _app_build_check_platform_support "$feature_dir"
    case $? in
    0)
      return 0
      ;;
    1)
      return 1
      ;;
    esac

    local feature_dir=$(dirname "$feature_dir" | $GNU_GREP -Po '.*feature/.*\.feature')
  done

  printf '%s\n' $APP_PLATFORM_SUPPORTED_PLATFORMS | $GNU_GREP -cqm1 "$target_platform"
}

_app_build_check_platform_support() {
  [ ! -e "$1/supported-platforms" ] && return 2

  grep -cqm1 "$target_platform" "$1/supported-platforms" 2>/dev/null
}

_app_build_correct_permissions() {
  local permissions=$(stat $IO_STAT_ARGS $1)
  chmod $permissions $buildfile_output_package_file $1
}

_buildfile_format_shell_scripts() {
  [ -n "$_OPTN_INSTALL_DISABLE_SHFMT" ] && return 1

  _shell_script_is_shell_script $buildfile_output_package_file && shfmt -w $buildfile_output_package_file
}
