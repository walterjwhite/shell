_pf_concat() {
	local _type=$1

	printf '###\n' >>$_TARGET
	printf '# %s\n' "$_type" >>$_TARGET

	if [ -e $FIREWALL/$_type ]; then
		for _MATCHING_FILE in $(find $FIREWALL/$_type \( -type f -or -type l \) ! -name 'rules.pf' | sort -V); do
			_pf_include_file $_type $_MATCHING_FILE
		done
	fi

	printf '\n' >>$_TARGET
}

_pf_include_file() {
	if [ -z "$2" ]; then
		_WARN "Include filename is empty."
		return
	fi

	case $1 in
	anchor)
		local anchor_name=$(basename $2 | sed -e 's/\.generated$//' | tr '.' '_')

		printf 'anchor %s\n' "$anchor_name" >>$_TARGET

		case $2 in
		*.scheduled)
			return
			;;
		*)
			printf 'load anchor %s from "%s"\n\n' "$anchor_name" "$2" >>$_TARGET
			return
			;;
		esac
		;;
	table)
		local table_name=$(basename $2 | sed -e 's/\.generated$//' | tr '.' '_')
		printf 'table <%s> persist file "%s"\n' "$table_name" "$2" >>$_TARGET
		return
		;;
	esac


	printf 'include "%s"\n' "$2" >>$_TARGET
}
