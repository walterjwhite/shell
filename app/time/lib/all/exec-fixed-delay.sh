_time_exec_fixed_delay() {
	_require "$_FUTURE_DATE_TIME" "_FUTURE_DATE_TIME -dt"
	_require "$_FORMAT" _FORMAT

	_CURRENT_EPOCH=$(date +%s)
	_TARGET_EPOCH=$(date $_CONF_DATE_OPTIONS "$_FORMAT" "$_FUTURE_DATE_TIME" +%s)
	_DELAY=$(($_TARGET_EPOCH - $_CURRENT_EPOCH))
}
