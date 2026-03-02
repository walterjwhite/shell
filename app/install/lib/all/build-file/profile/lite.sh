_buildfile_inject_lite() {
  $GNU_GREP -Pcq '^(init |readonly REQUIRED_ARGUMENTS=|readonly REQUIRED_APP_CONF=)' $1 && exit_with_error "files may not contain init or required_arguments"

  _buildfile_inject_header


  _buildfile_imports lib $1
  _buildfile_imports constant $1
  _buildfile_imports cfg $1
  unset buildfile_included_cfg

  _buildfile_format_shell_scripts

  $GNU_GREP -Pvh '^(#|lib |cfg |constant )' $1 >>$buildfile_output_package_file
}
