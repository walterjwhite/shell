_imports_import() {
	_imports_get $1 $2
	_imports $1 $APP_BUILD_OUTPUT_FILE
}

_imports_get() {
	_RAW_IMPORTS=$($_CONF_GNU_GREP -P "^$1 " "$2" | sed -e "s/$1 //" | sort -u)
}

_imports() {
	[ -z "$_RAW_IMPORTS" ] && return 1

	_call $before_function

	local raw_import
	for raw_import in $_RAW_IMPORTS; do
		_import "$1" "$2" "$3$raw_import"
	done

	_imports_get $1 $2

	$_CONF_GNU_SED -i "/^$1 .*/d" $2
	_imports "$@"
}

_import() {
	local import_type=$1
	shift

	local import_ref="$2"

	case $import_ref in
	git:*)
		_setup_git_import "$import_ref"

		case $GIT_IMPORT_TARGET_FILE in
		*.feature/*)
			local feature_patha=$(printf '%s\n' $GIT_IMPORT_TARGET_FILE | $_CONF_GNU_GREP -Po '^feature/.*\.feature')
			local feature_pathb=$(printf '%s\n' $GIT_IMPORT_TARGET_FILE | sed -e 's/^.*\.feature//')
			import_type=$import_type git_import_path=$GIT_IMPORT_PROJECT _import_file_contents $1 $GIT_IMPORT_PATH/$feature_patha/$import_type/%s/$feature_pathb
			;;
		*)
			import_type=$import_type git_import_path=$GIT_IMPORT_PROJECT _import_file_contents $1 $GIT_IMPORT_PATH/$import_type/%s/$GIT_IMPORT_TARGET_FILE
			;;
		esac
		;;
	feature:*)
		local feature_path=$(printf '%s' $1 | $_CONF_GNU_GREP -Po 'feature.*\.feature')
		local feature_arg="${import_ref#*feature:}"
		_import_file_contents $1 $feature_path/$import_type/%s/$feature_arg
		;;
	*.feature/*)
		local feature_patha=$(printf '%s\n' $import_ref | $_CONF_GNU_GREP -Po '^feature/.*\.feature')
		local feature_pathb=$(printf '%s\n' $import_ref | sed -e 's/^.*\.feature//')
		_import_file_contents $1 $feature_patha/$import_type/%s/$feature_pathb
		;;
	.*)
		_import_file_contents $1 $import_type/%s/$import_ref
		;;
	*)
		_import_file_contents $1 $_PROJECT_ROOT/$import_type/%s/$import_ref
		;;
	esac
}

_import_file_contents() {
	local file=$1
	shift

	local platform_path=$(printf "$1" $_TARGET_PLATFORM)
	local all_path=$(printf "$1" all)

	_require_file "$file" "_import_file_contents"

	_import_has_matching_files $platform_path $all_path

	local file_to_import
	for file_to_import in $(find $platform_path $all_path \( -type f -or -type l \) -and ! -name '*.test' 2>/dev/null | sort -u); do
		printf '%s\n' "$IMPORTED" | $_CONF_GNU_GREP -Pcqm1 $file_to_import && {
			_DEBUG "$file_to_import was already imported"
			continue
		}

		IMPORTED="$file_to_import\n$IMPORTED"

		if [ -e ${file_to_import}.test ]; then
			${file_to_import}.test $APP_BUILD_OUTPUT_FILE
			if [ "$?" -eq "0" ]; then
				cat $file_to_import >>$file
			else
				_DEBUG "$file_to_import failed test"
			fi
		else
			cat $file_to_import >>$file
		fi
	done
}

_import_has_matching_files() {
	[ -n "$_OPTIONAL" ] && return

	find $1 $2 -type f -or -type l 2>/dev/null | grep -q . || _ERROR "_import_file_contents - no matching files found: $1 $2"
}

_import_filter_imports() {
	[ -z "$import_type" ] || [ -z "$git_import_path" ] && {
		cat -
		return
	}

	sed "/git:/! s/^$import_type /$import_type git:$git_import_path\//"
}

_inject_header() {
	printf '#!/bin/sh\n\n' >$APP_BUILD_OUTPUT_FILE
}

_inject_app_header() {
	printf 'set -a\n' >>$APP_BUILD_OUTPUT_FILE

}

_inject_app_name() {
	printf '_APPLICATION_NAME=%s\n' $_TARGET_APPLICATION_NAME >>$APP_BUILD_OUTPUT_FILE
}
