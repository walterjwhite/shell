search_git_branch_contains_file() {
  [ $# -ne 2 ] && {
    log_warn "two arguments are required, branch / ref and file path."
    return
  }

  git ls-tree --full-tree -r "$1" "$2" | grep -cqm1 '.'
}
