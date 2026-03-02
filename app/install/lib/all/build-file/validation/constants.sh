_buildfile_constants_has_invalid() {
  local invalid_constants
  local buildfile_namespace
  local const_name

  buildfile_namespace=$(basename "$buildfile_output_package_file" | $GNU_SED 's/\.[^.]*$//' | tr '[:lower:]-' '[:upper:]_')

  local format_invalid=$($GNU_GREP -nE '^[[:space:]]*readonly [A-Za-z][A-Za-z0-9_]*=' $buildfile_output_package_file |
    $GNU_SED -E 's/^[0-9]*:[[:space:]]*readonly //; s/=.*//; /^[A-Z][A-Z_0-9]*$/d' | sort -u)

  [ -z "$format_invalid" ] || {
    log_warn 'invalid constant names (format)'
    printf '%s\n' "$format_invalid"
    exit_with_error "$buildfile_output_package_file has invalid constant names format (Rule 3: Must be [A-Z][A-Z_0-9]+)"
  }

  local buildfile_namespace_invalid=""
  while IFS= read -r const_name; do
    [ -z "$const_name" ] && continue
    case "$const_name" in
    ${buildfile_namespace}_*)
      ;;
    [A-Z]*_*)
      ;;
    *)
      buildfile_namespace_invalid="$buildfile_namespace_invalid$const_name
"
      ;;
    esac
  done <<EOF
$($GNU_GREP -nE '^[[:space:]]*readonly [A-Z][A-Z_0-9]*=' $buildfile_output_package_file |
    $GNU_SED -E 's/^[0-9]*:[[:space:]]*readonly //; s/=.*//')
EOF

  [ -z "$buildfile_namespace_invalid" ] && return

  log_warn 'constants missing namespace prefix'
  printf '%s\n' "$buildfile_namespace_invalid" | sort -u

  exit_with_error "$buildfile_output_package_file has constants missing namespace prefix (Rule 3 - must have any NAMESPACE_ prefix)"
}
