_buildfile_invalid_filenames_is_valid() {

  buildfile_filename="${buildfile_output_package_file##*/}"

  case "$buildfile_output_package_file" in
  */files/*)
    return 0
    ;;
  esac

  case "$buildfile_filename" in
  *[[:space:]]*)
    exit_with_error "$buildfile_output_package_file contains spaces"
    ;;
  *[^a-zA-Z0-9._\-]*)
    exit_with_error "$buildfile_output_package_file contains special characters"
    ;;
  *)
    return 0
    ;;
  esac
}
