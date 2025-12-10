_git_delete_date() {
	_DELETE_DATE=$(date -v -${_CONF_GIT_DELETE_PERIOD_IN_DAYS}d +%Y/%m/%d)
}
