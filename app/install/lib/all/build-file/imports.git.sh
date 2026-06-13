
_buildfile_import_filter_imports() {
  [ -z "$import_type" ] || [ -z "$git_import_path" ] && {
    cat -
    return
  }

  sed "/git:/! s/^$import_type /$import_type git:$git_import_path\//"
}
