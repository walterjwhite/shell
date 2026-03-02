_buildfile_inject_header() {
  printf '#!/bin/sh\n\n' >$buildfile_output_package_file
}

_buildfile_inject_constants() {
  printf 'readonly APPLICATION_NAME=%s\n' $target_application_name >>$buildfile_output_package_file
}

_buildfile_inject_app_constants() {
  _buildfile_imports constant $1 "application platform platform.resolved"
}

_buildfile_inject_cfg_before() {
  [ -n "$buildfile_included_cfg" ] && return 2
  buildfile_included_cfg=1

  local includes=$(printf '%s\n' "$buildfile_raw_imports" | sed -e 's/feature://' -e 's/.\///g' -e 's/^.$//' -e 's/ . / /' | tr -s '[:space:]' '\n' | sort -u | tr '\n' ' ')

  [ -z "$includes" ] && return 2


  buildfile_included_cfg=1

  printf '_include_optional %s\n' "$includes" >>$buildfile_output_package_file
  printf '_metadata_load\n' >>$buildfile_output_package_file
}
