_find_public_functions() {
  (
    for input_path in "$@"; do
      _find_files "$input_path"
    done
  ) | sort -u | while IFS= read -r script_file; do
    awk '
      {
        line = $0
        sub(/#.*/, "", line)

        if (match(line, /^[[:space:]]*function[[:space:]]+([a-z][[:alnum:]_]*)[[:space:]]*(\(\))?[[:space:]]*;?[[:space:]]*\{?[[:space:]]*$/, m)) {
          printf "%s:%d:\033[91m%s\033[0m\n", FILENAME, NR, m[1]
          next
        }

        if (match(line, /^[[:space:]]*([a-z][[:alnum:]_]*)[[:space:]]*\(\)[[:space:]]*;?[[:space:]]*\{?[[:space:]]*$/, m)) {
          printf "%s:%d:\033[91m%s\033[0m\n", FILENAME, NR, m[1]
        }
      }
    ' "$script_file"
  done
}

_find_files() {
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

  log_warn 'path not found: %s\n' "$path"
}
