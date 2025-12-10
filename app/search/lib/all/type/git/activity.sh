_SEARCH_GIT_ACTIVITY() {
	if [ ! -e $_PROJECT_PATH/.activity ]; then
		_WARN "No activity in $_PROJECT_PATH/.activity"
		return
	fi

}
