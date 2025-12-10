#!/bin/sh

_git_behind_remote() {
	local _remote=origin

	if [ $# -gt 0 ]; then
		_remote=$1
		shift
	fi

	git status >/dev/null 2>&1
	if [ $? -gt 0 ]; then
		_ERROR "Unable to check status of git, are you in a git work tree?"
	fi

	_GIT_PROJECT_BEHIND_REMOTE=$(git rev-list HEAD..$_remote --count)
}
