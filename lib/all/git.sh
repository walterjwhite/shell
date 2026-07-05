_git_do_clone() {
  [ -e $2 ] && {
    local opwd=$PWD
    cd $2
    git pull || log_warn "unable to update: $2"

    cd $opwd

    return
  }

  git clone $1 $2 && log_detail "using $1 -> $2"
}

_git_is_clean() {
  [ -n "$(git status --porcelain "$@")" ] && exit_with_error "working directory is dirty, please commit changes first"
}
