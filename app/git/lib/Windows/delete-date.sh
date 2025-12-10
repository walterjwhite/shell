_git_delete_date() {
	_DELETE_DATE=$(date --date="$(date) - $_CONF_GIT_DELETE_PERIOD_IN_DAYS day" +%Y/%m/%d)
}
