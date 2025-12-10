_SEARCH_GIT_BRANCH_CONTAINS_FILE() {
	[ $# -ne 2 ] && {
		_WARN "2 arguments are required, branch / ref and file path."
		return
	}

	git ls-tree --full-tree -r "$1" "$2" | grep -cqm1 '.'
}
