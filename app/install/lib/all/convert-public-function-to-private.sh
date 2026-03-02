_convert_public_function_to_private() {
  local public_name="$1"
  shift

  case "$public_name" in
  '' | _* | *[![:alnum:]_]* | [0-9]*)
    exit_with_error "convert-public-function-to-private: invalid public function name: $public_name"
    ;;
  esac

  local private_name="_$public_name"
  local tmp_files
  tmp_files=$(mktemp)
  exit_defer rm -f "$tmp_files"

  if [ "$#" -eq 0 ]; then
    set -- "."
  fi

  (
    for input_path in "$@"; do
      _convert_public_function_to_private_find_files "$input_path"
    done
  ) | sort -u >"$tmp_files"

  local declaration_count
  declaration_count=$(_convert_public_function_to_private_count_declarations "$public_name" "$tmp_files")

  [ "$declaration_count" -eq 0 ] && {
    log_warn "convert-public-function-to-private: function declaration not found: $public_name"
  }

  local changed_count=0
  while IFS= read -r script_file; do
    [ -f "$script_file" ] || continue

    if grep -Eq "(^|[^[:alnum:]_])$public_name([^[:alnum:]_]|$)" "$script_file" 2>/dev/null; then
      sed -i -E "s/(^|[^[:alnum:]_])$public_name([^[:alnum:]_]|$)/\\1$private_name\\2/g" "$script_file"
      changed_count=$((changed_count + 1))
    fi
  done <"$tmp_files"

  log_info "convert-public-function-to-private: renamed $public_name -> $private_name in $changed_count file(s)"
}

_convert_public_function_to_private_count_declarations() {
  local function_name="$1"
  local files_list="$2"

  while IFS= read -r script_file; do
    [ -f "$script_file" ] || continue

    awk -v fn="$function_name" '
      {
        line = $0
        sub(/#.*/, "", line)

        if (match(line, "^[[:space:]]*function[[:space:]]+" fn "[[:space:]]*(\\(\\))?[[:space:]]*;?[[:space:]]*\\{?[[:space:]]*$")) {
          count++
          next
        }

        if (match(line, "^[[:space:]]*" fn "[[:space:]]*\\(\\)[[:space:]]*;?[[:space:]]*\\{?[[:space:]]*$")) {
          count++
        }
      }
      END {
        print count + 0
      }
    ' "$script_file"
  done <"$files_list" | awk '{ total += $1 } END { print total + 0 }'
}

_convert_public_function_to_private_find_files() {
  local path="$1"

  if [ -f "$path" ]; then
    printf '%s\n' "$path"
    return
  fi

  if [ -d "$path" ]; then
    find "$path" -type f \
      \( -name '*.sh' -o -name '*.run' -o -path '*/bin/*' \) \
      -print
    return
  fi

  log_warn "path not found: $path"
}
