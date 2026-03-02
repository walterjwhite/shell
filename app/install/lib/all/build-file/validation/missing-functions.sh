_build_list_declared_functions() {
  $GNU_GREP -Ph '^\s*(function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)\s*\{?$' $buildfile_output_package_file |
    $GNU_SED -E 's/^\s*(function\s+)?//; s/\s*\(.*//' | sort -u
}

_build_list_referenced_commands() {
  $GNU_SED -E "
    s/'[^']*'/ /g;
    s/\"[^\"]*\"/ /g;
    s/\\\`[^\\\`]*\\\`/ /g;
    s/#.*//;
    s/&&/\\
/g;
    s/\\|\\|/\\
/g;
    s/;/\\
/g;
    s/\\|/\\
/g;
    s/[(){}]/ /g;
  " "$buildfile_output_package_file" | awk '
    BEGIN {
      validation_keywords="if then elif else fi while until do done in esac function time ! ["
      skip_line="for select case"
      split(validation_keywords, kw, " ")
      for (i in kw) is_kw[kw[i]] = 1
      split(skip_line, sk, " ")
      for (i in sk) is_skip[sk[i]] = 1
    }
    {
      if ($0 ~ /^[ \t]*$/) next
      
      for (i = 1; i <= NF; i++) {
        token = $i
        
        if (token == "") continue
        if (token == "!") continue
        if (token == "[") continue
        if (token == "]") continue
        if (token == "[[") continue
        if (token == "]]") continue
        
        if (token ~ /\$/) continue
        
        if (token ~ /^[A-Za-z_][A-Za-z0-9_]*=/) continue

        if (token in is_skip) next
        
        if (token in is_kw) continue
        
        print token
        break
      }
    }
  ' | $GNU_SED -E 's/[^A-Za-z0-9_./-].*$//' | $GNU_SED -E '/^$/d' | sort -u
}

_build_is_command_or_builtin() {
  command -v "$1" >/dev/null 2>&1 || return 1

  if type "$1" 2>/dev/null | $GNU_GREP -qi 'function'; then
    return 1
  fi

  return 0
}

_build_has_missing_functions() {
  local declared_functions referenced_commands missing_functions

  declared_functions=$(_build_list_declared_functions)
  referenced_commands=$(_build_list_referenced_commands)

  [ -z "$referenced_commands" ] && return

  local command_name
  for command_name in $referenced_commands; do
    case " $declared_functions " in
    *" $command_name "*) continue ;;
    esac

    _build_is_command_or_builtin "$command_name" && continue

    missing_functions="$missing_functions
$command_name"
  done

  [ -z "$missing_functions" ] && return

  log_warn 'missing functions or commands'

  local missing_func
  for missing_func in $missing_functions; do
    [ -z "$missing_func" ] && continue

    printf "%s\n" "$missing_func"
    $GNU_GREP -nm5 "\b$missing_func\b" "$buildfile_output_package_file" |
      sed 's/^/  line /' |
      head -5
  done

  log_warn "$buildfile_output_package_file references functions or commands that do not exist"
}
