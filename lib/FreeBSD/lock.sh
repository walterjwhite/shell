_lock() {
	local lock_timeout=$1
	shift

	local lock_file=$1
	shift

	[ "$#" -eq 0 ] && _ERROR "_lock requires at least 3 arguments, timeout (1), lock file (2), and cmd (3)"

	lockf -t $lock_timeout $lock_file "$@"
}
