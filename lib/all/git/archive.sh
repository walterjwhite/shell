_git_archive_filter() {
    local repository=$1
    local path=$2
    local target=$3
  git archive --remote $repository $path | tar -x --exclude='*/*.secret/*' --exclude='*/*.archived/*' -C $target
}
