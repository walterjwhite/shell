_git_archive_filter() {
  local repository=$1
  local git_ref=$2
  local path=$3
  local file_extension_filter=$4
  local target=$5
  [ -z "$git_ref" ] && git_ref=main

  git archive --remote $repository $git_ref $path | tar -x -C $target

  find $target \( -type f -or -type l \) -and \( -path '*.secret*' -or -path '*.archived*' \) -delete

  [ -n "$file_extension_filter" ] && find $target -type f ! -name "$file_extension_filter" -delete

  find $target -depth -type d -empty -delete
}
