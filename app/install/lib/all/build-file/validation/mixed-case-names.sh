_buildfile_mixed_case_names_has_invalid() {
  local mixed_case_functions
  local mixed_case_variables

  mixed_case_functions=$(
    $GNU_GREP -nE '^[[:space:]]*(function[[:space:]]+)?[_a-zA-Z][_a-zA-Z0-9]*[[:space:]]*\(\)' "$buildfile_output_package_file" |
      $GNU_SED -E 's/^([0-9]+):[[:space:]]*(function[[:space:]]+)?([_a-zA-Z][_a-zA-Z0-9]*)[[:space:]]*\(\).*/\3/' |
      $GNU_GREP -E '[a-z]' |
      $GNU_GREP -E '[A-Z]' |
      sort -u
  )

  mixed_case_variables=$(
    {
      $GNU_GREP -nE '^[[:space:]]*local[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$buildfile_output_package_file" |
        awk '
          function count_cmdsub_opens(text, tmp, count) {
            tmp = text
            count = 0
            while (match(tmp, /\$\(/)) {
              count++
              tmp = substr(tmp, RSTART + RLENGTH)
            }
            return count
          }

          function count_paren_closes(text, tmp, count) {
            tmp = text
            count = 0
            while (match(tmp, /\)/)) {
              count++
              tmp = substr(tmp, RSTART + RLENGTH)
            }
            return count
          }

          {
            line = $0
            sub(/^[0-9]+:[[:space:]]*local[[:space:]]+/, "", line)
            gsub(/"([^"\\]|\\.)*"/, "", line)
            gsub(/\047([^\\\047]|\\.)*\047/, "", line)

            field_count = split(line, fields, /[[:space:]]+/)
            in_assignment = 0
            cmdsub_depth = 0

            for (i = 1; i <= field_count; i++) {
              field = fields[i]
              if (field == "") {
                continue
              }

              if (in_assignment) {
                cmdsub_depth += count_cmdsub_opens(field)
                cmdsub_depth -= count_paren_closes(field)
                if (cmdsub_depth <= 0) {
                  in_assignment = 0
                  cmdsub_depth = 0
                }
                continue
              }

              if (field ~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
                print field
                continue
              }

              if (field ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
                split(field, parts, "=")
                if (parts[1] != "") {
                  print parts[1]
                }

                value = substr(field, length(parts[1]) + 2)
                cmdsub_depth = count_cmdsub_opens(value) - count_paren_closes(value)
                if (cmdsub_depth > 0) {
                  in_assignment = 1
                } else {
                  cmdsub_depth = 0
                }
              }
            }
          }
        '

      $GNU_GREP -nE '^[[:space:]]*readonly[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=' "$buildfile_output_package_file" |
        $GNU_SED -E 's/^[0-9]+:[[:space:]]*readonly[[:space:]]+//' |
        $GNU_SED -E 's/=.*//'

      $GNU_GREP -nE '^[[:space:]]*(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=' "$buildfile_output_package_file" |
        $GNU_SED -E 's/^[0-9]+:[[:space:]]*(export[[:space:]]+)?//' |
        $GNU_SED -E 's/=.*//'
    } |
      $GNU_SED -E '/^$/d' |
      sort -u |
      $GNU_GREP -E '[a-z]' |
      $GNU_GREP -E '[A-Z]' |
      sort -u
  )

  [ -z "$mixed_case_functions" ] && [ -z "$mixed_case_variables" ] && return 0

  log_warn 'mixed-case names are not allowed'
  [ -z "$mixed_case_functions" ] || {
    printf 'functions:\n'
    printf '%s\n' "$mixed_case_functions"
  }
  [ -z "$mixed_case_variables" ] || {
    printf 'variables:\n'
    printf '%s\n' "$mixed_case_variables"
  }

  exit_with_error "$buildfile_output_package_file has mixed-case function or variable names (use all lowercase with underscores, or uppercase constants)"
}
