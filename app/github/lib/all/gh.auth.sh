_github_auth() {
	gh auth status >/dev/null || {
		_INFO "Logging into github"
		gh auth login

		return
	}

	_DETAIL "Already logged into github"

	[ -z $_GIT_USERNAME ] && _GIT_USERNAME=$(secrets get -out=stdout $_CONF_GITHUB_USERNAME_KEY 2>/dev/null)

	_require "$_GIT_USERNAME" "_GIT_USERNAME - check secrets key: $_CONF_GITHUB_USERNAME_KEY"
}
