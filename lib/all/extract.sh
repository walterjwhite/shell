_extract_extract() {
  if [ $# -lt 2 ]; then
    log_warn "expecting 2 arguments, source file, and target to extract to"
    return 1
  fi

  log_info "extracting $1"

  [ -n "$clean" ] && {
    rm -rf $2
    mkdir -p $2
  }

  case $1 in
  *.tar.gz | *.tgz | *.tar.bz2 | *.tbz2 | *.tar.xz)
    tar xf $1 -C $2
    ;;
  *.zip)
    unzip -q $1 -d $2
    ;;
  *)
    log_warn "extension unsupported - $1"
    return 2
    ;;
  esac
}
