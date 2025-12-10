_git_delete_branches() {
	for _BRANCH in $(_git_delete_get_branches); do
		gco $_BRANCH

		_git_is_ahead && continue

		local has_changes=$(gcs $_DELETE_DATE | wc -l)
		if [ "$has_changes" -eq "0" ]; then
			_WARN "delete $_BRANCH - NO activity since $_DELETE_DATE"

			[ -z "$_OPTN_GIT_DELETE_OLD_BRANCHES_WARN_ONLY" ] && {
				[ -z "$_GIT_LOCAL" ] && _git_delete_remote_branch

				_git_delete_local_branch
			}
		else
			_DEBUG "$_BRANCH is active (since $_DELETE_DATE), retaining (!delete)"
		fi
	done

	_INFO "done archiving/deleting old branches - $PWD"
}

_git_delete_get_branches() {
	local git_options
	[ -z "$_GIT_LOCAL" ] && {
		_WARN "deleting local AND remote branches"
		git_options="-a"
	}

	gb $git_options
}

_git_delete_local_branch() {
	gco $(gb -a | grep -v "^${_BRANCH}$" | head -1)
	gb -D $_BRANCH 2>/dev/null
	[ $(git branch --list $_BRANCH | wc -l) -eq 0 ] && {
		_DETAIL "deleted $_BRANCH locally"
		_REPOSITORY_HAS_DELETED_BRANCHES=1
	} || _WARN "unable to delete $_BRANCH locally"
}

_git_delete_remote_branch() {
	local git_remote
	for git_remote in $(git remote); do
		_git_branch_exists_on_remote || {
			_WARN "$_BRANCH does not exist on remote (origin)"
			continue
		}

		_WARN "Deleting: $_BRANCH"

		if [ $_CONF_GIT_DELETE_DRYRUN -gt 0 ]; then
			_WARN "DRYRUN: git push $git_remote :$_BRANCH"
			continue
		fi

		git push $git_remote :$_BRANCH || {
			_WARN "Unable to delete branch on remote, aborting: $_BRANCH"
			continue
		}

		_REPOSITORY_HAS_DELETED_BRANCHES=1
	done
}

_git_branch_exists_on_remote() {
	[ "$(git ls-remote --heads origin refs/heads/$_BRANCH | wc -l)" -eq "0" ] && return 1

	return 0
}

_git_create_backup_mirror() {
	_get_project_directory

	_REPOSITORY_CLONE_FILE=$_CONF_APPLICATION_DATA_PATH/$(basename $PWD)-$(date +$_CONF_GIT_BACKUP_DATE_TIME_FORMAT).backup
	git clone --mirror $_PROJECT_PATH $_REPOSITORY_CLONE_FILE
}

_git_is_ahead() {
	local status=$(git status -sb)-
	local ahead=$(printf '%s\n' "$_status" | $_CONF_GNU_GREP -Pc "^##.{1,}\[ahead [\d]{1,}\]$")
	if [ "$ahead" -gt "0" ]; then
		_WARN "$_BRANCH is ahead: $ahead"
		_DETAIL "$status"

		return 0
	fi

	return 1
}
