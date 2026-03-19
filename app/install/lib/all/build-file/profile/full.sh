_buildfile_inject_full() {
  _buildfile_inject_header

  : ${lib_imports:=$BUILDFILE_FULL_LIB}
  _buildfile_imports lib $1 "$lib_imports"

  _buildfile_inject_constants
  _buildfile_inject_app_constants $1

  validation_required_arguments $1

  : ${cfg_imports:="$BUILDFILE_FULL_CFG ./$target_application_name"}
  buildfile_optional=1 before_function=_buildfile_inject_cfg_before _buildfile_imports cfg $1 "$cfg_imports"
  unset buildfile_included_cfg


  : ${init_imports:="$BUILDFILE_FULL_INIT"}
  buildfile_optional=1 _buildfile_imports init $1 "$init_imports"

  chmod +x $buildfile_output_package_file $1

  _buildfile_format_shell_scripts

  $GNU_GREP -Pvh '^(#|var |lib |cfg |constant |init |readonly REQUIRED_ARGUMENTS=)' $1 >>$buildfile_output_package_file

  [ -n "$post_build_function" ] && $post_build_function

  [ -z "$no_remove_unused_functions" ] && {
    _buildfile_remove_unused_functions
    _buildfile_remove_unused_variables
  }

  [ "$conf_log_level" -eq 0 ] && _build_has_missing_functions
}
