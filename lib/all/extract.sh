_extract() {
	if [ $# -lt 2 ]; then
		_WARN "Expecting 2 arguments, source file, and target to extract to"
		return 1
	fi

	_INFO "### Extracting $1"

	local _extension=$(printf '%s' "$1" | $_CONF_GNU_GREP -Po "\\.(tar\\.gz|tar\\.bz2|tbz2|tgz|zip|tar\\.xz)$")
	local sudo
	[ -n "$_SUDO_REQUIRED" ] && sudo=_sudo

	[ -n "$_CLEAN" ] && {
		$sudo rm -rf $2
		$sudo mkdir -p $2
	}

	case $_extension in
	".tar.gz" | ".tgz" | ".tar.bz2" | ".tbz2" | ".tar.xz")
		$sudo tar xf $1 -C $2
		;;
	".zip")
		$sudo unzip -q $1 -d $2
		;;
	*)
		_WARN "extension unsupported - $_extension $1"
		return 2
		;;
	esac
}
