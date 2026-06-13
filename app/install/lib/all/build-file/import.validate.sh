_buildfile_import_validate_paths() {
  find "$@" \( -type f -or -type l \) \
    -and \( ! -name '*.test' ! -name '*_test.sh' \) \
    2>/dev/null | grep -q -m 1 . || {
    exit_with_error "import - no matching files found in paths: $* | $target"
    return 1
  }
}
