_github_review() {
	[ $_CONF_GITHUB_REVIEW -eq 1 ] && gd
}

_github_cleanup_staged() {
	rm -rf $_GITHUB_PROJECT_PATH
}

_github_unstage_changes() {
	_WARN "Unstaging changes: $_GITHUB_PROJECT_SYNC_PATH"
	_github_cleanup_staged
}

_github_stage_changes() {
	cd $_PWD

	_continue_if "Continue with staging changes to github?" "Y/n" || {
		_github_unstage_changes
		return 1
	}

	_github_tag
}
