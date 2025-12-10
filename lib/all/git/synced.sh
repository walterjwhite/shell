_git_has_uncommitted_work() {
	[ -n "$(git status --porcelain)" ] && return 1

	return 0
}

_git_synced_with_remote() {
	local branch_name=$1

	local remote_hash=$(_git_remote_hash $branch_name)
	local local_hash=$(git-head)

	[ "$local_hash" = "$remote_hash" ] && return 0

	return 1
}

_git_remote_hash() {
	[ -z "$git_type" ] && git_type=heads

	git ls-remote $(git remote -v | head -1 | awk {'print$2'}) | grep "refs/$git_type/${1}$" | cut -f1
}
