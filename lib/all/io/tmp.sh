_defer_cleanup_tmp() {
	[ -z "$_TMP_CLEANUP_DEFERS" ] && _defer _cleanup_tmp

	_TMP_CLEANUP_DEFERS="${_TMP_CLEANUP_DEFERS:+$_TMP_CLEANUP_DEFERS }$1"
}

_cleanup_temp() {
	[ -z "$_TMP_CLEANUP_DEFERS" ] && return 1

	rm -rf $_TMP_CLEANUP_DEFERS
	unset _TMP_CLEANUP_DEFERS
}
