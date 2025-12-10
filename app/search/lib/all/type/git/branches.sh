_SEARCH_GIT_BRANCHES() {
	git branch -a | grep --color $_OPTIONS "$1"
}
