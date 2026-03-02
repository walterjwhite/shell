_buildfile_invalid_functions_has_invalid_name() {
  local invalid_functions
  local buildfile_namespace
  local buildfile_is_bin_file

  buildfile_namespace=$(basename "$buildfile_output_package_file" | $GNU_SED 's/\.[^.]*$//; s/[-.]/_/g')

  case "$buildfile_output_package_file" in
  */bin/*)
    buildfile_is_bin_file=1
    ;;
  *)
    buildfile_is_bin_file=0
    ;;
  esac

  local all_functions=$(_buildfile_invalid_functions_list_names)

  local format_invalid=$(printf '%s\n' "$all_functions" |
    $GNU_SED -E '
      /^_[a-z][a-z0-9_]*$/d
      /^[a-z][a-z0-9_]*$/d
    ' | sort -u)

  [ -z "$format_invalid" ] || {
    log_warn 'invalid function names'
    printf '%s\n' "$format_invalid"

    local buildfile_rule_msg
    while IFS= read -r func_name; do
      [ -z "$func_name" ] && continue
      case "$func_name" in
      _[A-Z]*)
        buildfile_rule_msg="Rule 1 - Private functions must be lowercase"
        ;;
      [A-Z]*)
        buildfile_rule_msg="Rule 2 - Public functions must be lowercase"
        ;;
      *)
        buildfile_rule_msg="Rule 1/2 - Invalid function name format"
        ;;
      esac
    done <<EOF
$format_invalid
EOF

    exit_with_error "$buildfile_output_package_file has invalid function names ($buildfile_rule_msg): [a-z][a-z0-9_]+ or _[a-z][a-z0-9_]+"
  }

  [ "$buildfile_is_bin_file" -eq 1 ] && return 0

  local buildfile_namespace_invalid=""
  local func_name

  while IFS= read -r func_name; do
    [ -z "$func_name" ] && continue
    case "$func_name" in
    _${buildfile_namespace}_* | ${buildfile_namespace}_*)
      ;;
    _[a-z]*_* | [a-z]*_*)
      ;;
    *)
      buildfile_namespace_invalid="$buildfile_namespace_invalid$func_name
"
      ;;
    esac
  done <<EOF
$all_functions
EOF

  [ -z "$buildfile_namespace_invalid" ] && return 0

  log_warn 'functions missing namespace prefix'
  printf '%s\n' "$buildfile_namespace_invalid" | sort -u

  exit_with_error "$buildfile_output_package_file has functions missing namespace prefix (should have any _namespace_ or namespace_ prefix)"
}

_buildfile_invalid_functions_list_names() {
  awk '
    {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)

      if (match(line, /^[[:space:]]*(function[[:space:]]+)?([_a-zA-Z][_a-zA-Z0-9]*)[[:space:]]*\(\)[[:space:]]*(\{)?[[:space:]]*$/, m)) {
        print m[2]
      }
    }
  ' "$buildfile_output_package_file"
}
