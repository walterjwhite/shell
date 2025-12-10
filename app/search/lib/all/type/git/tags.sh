_SEARCH_GIT_TAGS() {
	git tag | grep --color $_OPTIONS "$1"
}
