search_git_branches() {
  git branch -a | grep --color $options "$1"
}
