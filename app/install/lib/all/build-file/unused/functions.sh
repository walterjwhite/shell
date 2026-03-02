_buildfile_remove_unused_functions() {
  local index=0
  while :; do
    local unused_functions=$(_buildfile_unused_functions)

    [ -z "$unused_functions" ] && break

    log_debug "remove function:$buildfile_index:$unused_functions"

    local unused_function
    for unused_function in $unused_functions; do
      _buildfile_remove_unused_function $unused_function $buildfile_output_package_file
    done

    buildfile_index=$(($buildfile_index + 1))
  done
}

_buildfile_unused_functions() {
  local called_functions=$(_buildfile_called_functions | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')

  _buildfile_list_functions | $GNU_GREP -Pv "^${called_functions}$"
}

_buildfile_list_functions() {
  $GNU_GREP -Ph '^\s*_[a-z0-9_]+\s*\(\)\s*\{$' $buildfile_output_package_file | sed -e 's/().*//' -e 's/ //g' | sort -u
}

_buildfile_called_functions() {
  $GNU_GREP -Pho '_[a-z0-9_]{3,}( |$|\))' $buildfile_output_package_file | sed -e 's/ $//' -e 's/)//' | tr ' ' '\n' | sort -u
}

_buildfile_remove_unused_function() {
  local function_start=$(_buildfile_function_start $1 $2)
  local function_end=$(_buildfile_function_end $2 $function_start)

  warn_on_error=1 validation_require "$function_start" function_start || return 1
  warn_on_error=1 validation_require "$function_end" function_end || return 1

  log_debug "remove unused function: $1"
  $GNU_SED -i "$function_start,$function_end d" $2
}

_buildfile_function_start() {
  $GNU_GREP -Pnh "^\s*$1\s*\(\)\s*\{$" $2 | head -1 | cut -f1 -d:
}

_buildfile_function_end() {
  awk "NR > $2 { if (\$0 ~ /^\}$/) { print NR; exit } }" $1
}

_buildfile_unused_test() {
  :
}
