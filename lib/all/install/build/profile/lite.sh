_INJECT_LITE() {
	$_CONF_GNU_GREP -Pcq '^(init |_REQUIRED_ARGUMENTS )' $1 && _ERROR "Files may not contain init or _REQUIRED_ARGUMENTS"

	_inject_header

	case $1 in
	*.sh)
		_inject_app_name
		;;
	esac

	_inject_lib $1
	_inject_cfg $1

	chmod +x $APP_BUILD_OUTPUT_FILE $1

	_build_format_shell_scripts

	$_CONF_GNU_GREP -Pvh '^(#|lib |cfg )' $1 >>$APP_BUILD_OUTPUT_FILE
}
