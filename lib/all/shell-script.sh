_is_shell_script() {
	case $1 in
	*.sh)
		return 0
		;;
	esac

	head -1 $1 | $_CONF_GNU_GREP -Pcq 'sh$'
}
