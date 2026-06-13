_buildfile_missing_trailing_newline_check() {
  case $buildfile_output_package_file in
  */bin/* | *run | *.sh | *.lite | *.full)
    [ -f "$buildfile_output_package_file" ] || return 0
    [ -s "$buildfile_output_package_file" ] || return 0
    [ "$(tail -c1 "$buildfile_output_package_file" | wc -l)" -eq 1 ] || exit_with_error "$buildfile_output_package_file is missing a trailing newline"
    ;;
  *)
    log_debug "ignoring newline check: $buildfile_output_package_file"
    ;;
  esac
}
