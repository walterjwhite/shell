_CONFIGURE_COMPARE() {
	_load_extension $1
	_call _CONFIGURE_${1}_COMPARE || _ERROR "Unable to compare: _CONFIGURE_${1}_COMPARE"
}
