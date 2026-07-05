_buildfile_invalid_filenames_is_valid() {

  buildfile_filename="${buildfile_output_package_file##*/}"

  case "$buildfile_output_package_file" in
  */files/*)
    return 0
    ;;
  esac

  invalid_chars=$(printf '%s' "$buildfile_filename" | tr -d 'a-zA-Z0-9._-')

  if [ -n "$invalid_chars" ]; then
    local hex_bytes=$(printf '%s' "$buildfile_filename" | od -A n -t x1 | tr -d '\n' | sed 's/^ *//; s/  */ /g')
    exit_with_error "$buildfile_output_package_file contains special characters [$buildfile_filename] (Hex: $hex_bytes)"
  fi
}
