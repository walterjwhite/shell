_github_remove_patterns() {
	_EXCLUDE_PATTERN_FILE=$_CONF_APPLICATION_DATA_PATH/.exclude
	touch $_EXCLUDE_PATTERN_FILE

	_PATTERN_FILE=${_APPLICATION_CONFIG_PATH}.patterns
	if [ ! -e $_PATTERN_FILE ]; then
		_WARN "### Unable to check contents ###"
		return
	fi

	_INFO "### Checking contents ###"

	$_CONF_GNU_GREP --exclude-dir=.git -f $_PATTERN_FILE . -r | $_CONF_GNU_GREP -v -f $_EXCLUDE_PATTERN_FILE | $_CONF_GNU_GREP -f $_PATTERN_FILE --color
	if [ $? -eq 0 ]; then
		_ _continue_if "Accept patterns?" "Y/n"


	else
		_DEBUG "Project contents do NOT contain any matches"
	fi
}
