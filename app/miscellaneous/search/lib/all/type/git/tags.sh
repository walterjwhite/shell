search_git_tags() {
  git tag | grep --color $options "$1"
}
