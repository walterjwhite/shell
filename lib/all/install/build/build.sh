_app_build() {
	_PROJECT_ROOT=$(git rev-parse --show-toplevel)

	if [ ! -e .app ]; then
		_app_build_recursive
		return
	fi

	_app_build_instance
}

_app_build_recursive() {
	local app
	for app in $(find . -maxdepth 2 -type f -name .app | sed -e 's/\.app$//' | sort -u); do
		cd $app
		_app_build_instance
		cd ..
	done
}

_app_build_instance() {
	_TARGET_APPLICATION_NAME=$(basename $PWD)
	_INFO "Building $_TARGET_APPLICATION_NAME"

	SED_SAFE_PWD=$(_sed_safe $PWD)

	mkdir -p $_CONF_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME
	date >$_CONF_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/.build-date

	_app_build_determine_build_platforms
	_app_build_platforms
}

_app_build_determine_build_platforms() {
	[ -z "$_INSTALL_BUILD_ALL_PLATFORMS" ] && return

	[ -e supported-platforms ] && {
		_INSTALL_BUILD_PLATFORMS=$(cat supported-platforms)
		return
	}

	_INSTALL_BUILD_PLATFORMS=$SUPPORTED_PLATFORMS
}

_app_build_platforms() {
	for _TARGET_PLATFORM in $_INSTALL_BUILD_PLATFORMS; do
		_app_build_platform_name
		_app_build_init_artifact_dir

		printf '\n'
		_INFO "Building for $_TARGET_PLATFORM"

		_increase_indent
		_app_build_package_files
		_reset_indent
	done
}

_app_build_platform_name() {
	case $_TARGET_PLATFORM in
	*/*)
		_TARGET_SUB_PLATFORM=${_TARGET_PLATFORM#*/}
		_TARGET_PLATFORM=${_TARGET_PLATFORM%%/*}
		;;
	*) ;;
	esac
}

_app_build_init_artifact_dir() {
	rm -rf $_CONF_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM && mkdir -p $_CONF_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM
}

_app_build_package_files() {
	for f in $(_app_build_find_files); do
		_app_build_package_file $f
	done
}

_app_build_find_files() {
	find ./bin ./cfg ./files ./help ./post-setup ./setup ./feature -type f -and \( ! -path '*.secret/*' ! -path '*.secret' ! -path '*.archived/*' ! -path '*.archived' \) -and \( \
		\( -path '*/bin/all/*' -or -path "*/cfg/all*" -or -path '*/files/all/*' -or -path '*/help/all/*' -or -path "*/post-setup/all/*" -or -path '*/setup/all/*' \) -or \
		\( -path "*/bin/$_TARGET_PLATFORM/*" -or -path "*/cfg/$_TARGET_PLATFORM/*" -or -path "*/files/$_TARGET_PLATFORM/*" -or -path "*/help/$_TARGET_PLATFORM/*" -or -path "*/post-setup/$_TARGET_PLATFORM/*" -or -path "*/setup/$_TARGET_PLATFORM/*" \) \) 2>/dev/null |
		sort -r
}

_app_build_package_file() {
	_DETAIL "$1"

	_app_build_package_file_supports_platform $1 || {
		_WARN "Not building $1 as it does not support $_TARGET_PLATFORM"
		return 1
	}

	file_relative=$(printf '%s\n' "$1" | sed -e "s/\/$_TARGET_PLATFORM\//\//" -e 's/\/all\//\//' -e 's/.none$//' -e 's/.lite$//')
	APP_BUILD_OUTPUT_FILE=$_CONF_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$file_relative

	mkdir -p $(dirname $APP_BUILD_OUTPUT_FILE)

	case $1 in
	*run | */bin/*)
		_app_build_profile $1
		;;
	*/files/*.sh)
		APP_BUILD_PROFILE=LITE
		;;
	*)
		APP_BUILD_PROFILE=NONE
		;;
	esac

	_INJECT_$APP_BUILD_PROFILE $1

	_update_remove_commented_code $APP_BUILD_OUTPUT_FILE
	_build_has_invalid_local_var_name
	_build_has_invalid_function_name
	[ -n "$REMOVE_UNUSED_FUNCTIONS" ] && {
		_remove_unused_functions
		_remove_unused_variables
	}

	_find_duplicate_functions

	_update_constants $APP_BUILD_OUTPUT_FILE

	_app_build_correct_permissions $1

	_DEBUG "Built $1 -> [$_TARGET_PLATFORM] [$_PLATFORM]"
}

_app_build_package_file_supports_platform() {
	case "$1" in
	*/feature/*.feature/*) ;;
	*)
		return 0
		;;
	esac

	_app_build_check_supported_platforms $(dirname "$1" | $_CONF_GNU_GREP -Po '.*feature/.*\.feature')
}

_app_build_check_supported_platforms() {
	local feature_dir="$1"

	while [ -n "$feature_dir" ]; do
		_app_build_check_platform_support "$feature_dir"
		case $? in
		0)
			return 0
			;;
		1)
			return 1
			;;
		esac

		feature_dir=$(dirname "$feature_dir" | $_CONF_GNU_GREP -Po '.*feature/.*\.feature')
	done

	printf '%s\n' $SUPPORTED_PLATFORMS | $_CONF_GNU_GREP -cqm1 "$_TARGET_PLATFORM"
}

_app_build_check_platform_support() {
	[ ! -e "$1/supported-platforms" ] && return 2

	grep -cqm1 "$_TARGET_PLATFORM" "$1/supported-platforms" 2>/dev/null
}

_app_build_correct_permissions() {
	local permissions=$(stat $_CONF_INSTALL_STAT_ARGUMENTS $1)
	chmod $permissions $APP_BUILD_OUTPUT_FILE $1
}

_app_build_profile() {
	APP_BUILD_PROFILE=$(basename $1 | sed -e 's/^.*\.//' | tr '[:lower:]' '[:upper:]')
	case $APP_BUILD_PROFILE in
	FULL | LITE | NONE) ;;
	*)
		_DEBUG "Unknown Profile: $APP_BUILD_PROFILE, defaulting to FULL"
		APP_BUILD_PROFILE=FULL
		;;
	esac

	_DEBUG "Profile: $APP_BUILD_PROFILE"
}

_build_format_shell_scripts() {
	[ -n "$_OPTN_INSTALL_DISABLE_SHFMT" ] && return 1

	_is_shell_script $APP_BUILD_OUTPUT_FILE && shfmt -w $APP_BUILD_OUTPUT_FILE
}
