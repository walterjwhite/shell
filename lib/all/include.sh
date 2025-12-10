_include() {
	local include_file
	for include_file in "$@"; do
		[ -f $HOME/.config/walterjwhite/shell/$include_file ] && . $HOME/.config/walterjwhite/shell/$include_file
	done
}
