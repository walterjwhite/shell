_INJECT_FULL() {
	_inject_header

	_inject_app_header
	_inject_app_name

	_required_arguments $1

	_RAW_IMPORTS="$LIB" _imports lib $APP_BUILD_OUTPUT_FILE
	_inject_lib $1

	_OPTIONAL=1 _RAW_IMPORTS="$CFG . $_TARGET_APPLICATION_NAME" before_function=_inject_cfg_before _imports cfg $APP_BUILD_OUTPUT_FILE
	_inject_cfg $1

	_required_cfg
	_inject_init $1

	chmod +x $APP_BUILD_OUTPUT_FILE $1

	_build_format_shell_scripts

	$_CONF_GNU_GREP -Pvh '^(#|lib |cfg |init |_REQUIRED_ARGUMENTS)' $1 >>$APP_BUILD_OUTPUT_FILE
}

_inject_lib() {
	_imports_import lib $1
	unset IMPORTED
}

_inject_cfg() {
	before_function=_inject_cfg_before _imports_import cfg $1

	unset IMPORTED
}

_inject_cfg_before() {
	local imports=$(printf '%s\n' "$_RAW_IMPORTS" | sort -u | sed -e 's/feature://' -e 's/.\///g' -e 's/^.$//' -e 's/ . / /' | tr '\n' ' ')
	[ -z "$imports" ] && return 1

	printf '_include %s\n' "$imports" >>$APP_BUILD_OUTPUT_FILE
}

_inject_init() {
	_OPTIONAL=1 _import init $APP_BUILD_OUTPUT_FILE platform

	_import init $APP_BUILD_OUTPUT_FILE full


	_imports_import init $1

	unset IMPORTED
}
