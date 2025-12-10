lib io/file.sh

_patches() {
	local module
	for module in $@; do
		_module_set_log $module || {
			_WARN "$module already run, skipping"
			continue
		}

		_require_file "$OS_INSTALLER_SYSTEM_WORKSPACE" "$OS_INSTALLER_SYSTEM_WORKSPACE - Configuration directory does not exist"

		_module_run_build $module
	done
}

_module_set_log() {
	[ -z "$_INDEX" ] && _INDEX=0

	local module_logfile="/var/log/walterjwhite/${_INDEX}.build.${1}"

	local skip
	[ -e $module_logfile ] && skip=1

	_set_logfile $module_logfile
	_reset_indent

	_INDEX=$((_INDEX + 1))

	[ -z "$skip" ]
}

_module_run_build() {
	cd $OS_INSTALLER_SYSTEM_WORKSPACE

	local module=$1
	MODULE_NAME=$(printf '%s' $module | tr '[[:lower:]]' '[[:upper:]]')

	local module_exec=$(env | grep ^_${MODULE_NAME}_EXEC= | sed -e "s/^_${MODULE_NAME}_EXEC=//")
	local module_type=$(env | grep ^_${MODULE_NAME}_TYPE= | sed -e "s/^_${MODULE_NAME}_TYPE=//")
	local module_options=$(env | grep ^_${MODULE_NAME}_OPTIONS= | sed -e "s/^_${MODULE_NAME}_OPTIONS=//")
	local module_is_file=$(env | grep ^_${MODULE_NAME}_IS_FILE= | sed -e "s/^_${MODULE_NAME}_IS_FILE=//")

	local module_path=$(env | grep ^_${MODULE_NAME}_PATH= | sed -e "s/^_${MODULE_NAME}_PATH=//")
	local module_supports_container=$(env | grep ^_${MODULE_NAME}_SUPPORTS_CONTAINER= | sed -e "s/^_${MODULE_NAME}_SUPPORTS_CONTAINER=//")

	[ -z "$module_type" ] && module_type=f
	[ -z "$module_path" ] && module_path="$1/*"
	[ $module_is_file ] && module_path=$module


	if [ $(_module_find $module_type $module_path $module_options -print -quit | wc -l) -eq 0 ]; then
		_INFO "no patches found - $module_type $module_path $module_options"
		return
	fi

	_INFO "start - $module"

	_call _PATCH_${MODULE_NAME}_PRE

	local module_status
	if [ -n "$module_is_file" ]; then
		_PATCH_$MODULE_NAME $(_module_find $module_type $module_path $module_options -exec $_CONF_GNU_GREP -Pvh '(^#|^$)' {} + | tr '\n' ' ' | sed -e 's/ $/\n/')
		module_status=$?
	else
		if [ -z "$module_exec" ]; then
			_PATCH_$MODULE_NAME $(_module_find $module_type $module_path $module_options | sort)
			module_status=$?
		else
			_module_find $module_type $module_path $module_options -exec $module_exec
			module_status=$?
		fi
	fi

	_call _PATCH_${MODULE_NAME}_POST

	_module_log_status $module $module_status
}

_module_find() {
	local module_type=$1
	shift
	local module_path=$1
	shift

	local patch_path=physical
	[ -n "$container" ] && patch_path=container

	find . -type $module_type ! -path '*/.archived/*' -and \( -path '*/patches/any/*' -or -path "*/patches/$patch_path/*" \) -and \( -path "*/*.patch/$module_path" \) "$@" 2>/dev/null | sort

	return 0
}

_module_log_status() {
	if [ $2 -gt 0 ]; then
		_WARN "end - $1 error ($2)"
	else
		_INFO "end - $1 - success"
	fi
}

_module_get_patch_name() {
	_module_get_patch_path "$1" |
		sed -e "s/^\.\///" -e "s/\.patch$//" -e "s/^patches\///"
}

_module_get_patch_path() {
	printf '%s' "$1" | $_CONF_GNU_GREP -Po '^.*.\.patch'
}
