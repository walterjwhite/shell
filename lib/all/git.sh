_do_clone() {
	[ -e $2 ] && {
		local opwd=$PWD
		cd $2
		git pull || _ERROR "Unable to update : $2"

		cd $opwd

		return
	}

	git clone $1 $2 && _DETAIL "Using $1 -> $2"
}

_is_clean() {
	[ -n "$(git status --porcelain)" ] && _ERROR "Working directory is dirty, please commit changes first"
}
