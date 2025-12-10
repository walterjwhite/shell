_ACTION=$(basename $0)

_helper_main() {
	OPWD=$PWD

	for _LANGUAGE_PATH in $(find $_CONF_APPLICATION_LIBRARY_PATH/action/$_ACTION -mindepth 1 -maxdepth 1 -type f); do
		. "$_LANGUAGE_PATH"

		cd $OPWD
	done

	local error_count=0
	for _LANGUAGE_PATH in $(find $_CONF_APPLICATION_LIBRARY_PATH/action/$_ACTION -mindepth 1 -maxdepth 1 -type d ! -name $_ACTION); do
		_LANGUAGE=$(basename $_LANGUAGE_PATH)
		[ -e $_CONF_APPLICATION_LIBRARY_PATH/language/$_LANGUAGE.sh ] && {
			. $_CONF_APPLICATION_LIBRARY_PATH/language/$_LANGUAGE.sh
			cd $OPWD
		}

		[ $(_has_files $_LANGUAGE) -gt 0 ] && {
			_helper_run "$@" || error_count=$(($error_count + 1))
			cd $OPWD
		}

		unset _EXTENSION
	done

	[ $error_count -gt 0 ] && _ERROR "encountered $error_count error(s), check logs for errors"
}

_helper_run() {
	_FEATURE_NAME=${_ACTION}_${_LANGUAGE}
	_FEATURE_NAME=$(printf '%s' $_FEATURE_NAME | tr '[:lower:]' '[:upper:]')

	_is_feature_enabled $_FEATURE_NAME || {
		unset _FEATURE_NAME
		return 1
	}

	local error_count=0
	_INFO "$_ACTION [$(basename $PWD)] ($_LANGUAGE)"
	if [ -z "$_EXEC_CMD" ]; then
		if [ -e $_LANGUAGE_PATH ]; then
			for _EXECUTOR in $(find $_LANGUAGE_PATH $_LANGUAGE_PATH/bin -mindepth 1 -maxdepth 1 -type f ! -name '.*' 2>/dev/null); do
				case $_EXECUTOR in
				$_LANGUAGE_PATH/bin/*)
					_EXEC_CMD="$_EXECUTOR {} +"
					;;
				*)
					. $_EXECUTOR || error_count=$(($error_count + 1))
					cd $OPWD
					;;
				esac

				_helper_run_each || error_count=$(($error_count + 1))
			done

			unset _EXEC_CMD
			return $error_count
		fi
	fi

	_do_run || error_count=$(($error_count + 1))
	unset _EXEC_CMD

	return $error_count
}

_helper_run_each() {
	_SUB_FEATURE_NAME=${_FEATURE_NAME}_$(basename $_EXECUTOR | tr '[:lower:]' '[:upper:]' | tr '-' '_' | sed -e "s/\..*$//")

	_is_feature_enabled $_SUB_FEATURE_NAME || {
		unset _EXEC_CMD _SUB_FEATURE_NAME
		return
	}

	local error_count=0
	_do_run || error_count=$(($error_count + 1))
	unset _SUB_FEATURE_NAME

	cd $OPWD

	return $error_count
}

_do_run() {
	[ -n "$_NO_EXEC" ] && {
		unset _EXEC_CMD _EXEC_ALL_CMD _NO_EXEC
		return
	}

	local error_count=0
	if [ -n "$_SUPPORTS_CHANGED" ] && [ $_DEV_CHANGED -eq 1 ]; then
		_detail_action
		_exec_changed $_LANGUAGE || error_count=$(($error_count + 1))
	else
		if [ -n "$_EXEC_ALL_CMD" ]; then
			$_EXEC_ALL_CMD || error_count=$(($error_count + 1))
		else
			_detail_action
			_exec_all $_LANGUAGE || error_count=$(($error_count + 1))
		fi
	fi

	unset _EXEC_CMD _EXEC_ALL_CMD _NO_EXEC
	return $error_count
}

_exec_changed() {
	_changed "$1" | xargs -P$_CONF_DEV_FORMAT_PARALLEL -I _F $_EXEC_CMD _F
}

_changed() {
	git status -s | $_CONF_GNU_GREP -P "^(\?\?|A|M)" | awk {'print$2'} | grep "\\.${1}$"
}

_exec_all() {
	local exec_arg=-exec
	[ -n "$_EXEC_DIR_CMD" ] && {
		exec_arg=-execdir
		_EXEC_CMD="$_EXEC_DIR_CMD"
		unset _EXEC_DIR_CMD
	}

	[ -z "$_EXEC_CMD" ] && return

	type $1_find >/dev/null 2>&1 && {
		$1_find "$1" $exec_arg $_EXEC_CMD
		return
	}

	_helper_find "$1" $exec_arg $_EXEC_CMD
}

_has_files() {
	type $1_find >/dev/null 2>&1 && {
		$1_find "$1" -print -quit | wc -l
		return
	}

	_helper_find "$1" -print -quit | wc -l
}

_helper_find() {
	local file_extension_pattern="$1"
	shift

	case $file_extension_pattern in
		*.*)
			;;
		*)
			file_extension_pattern="*.$file_extension_pattern"
			;;
	esac

	find . -type f -name "$file_extension_pattern" \
		! -path '*/node_modules/*' \
		! -path '*/target/*' \
		! -path '*/.idea/*' \
		! -path '*/.git/*' \
		"$@"
}

_detail_action() {
	[ -n "$_SUB_FEATURE_NAME" ] && _DETAIL " $_SUB_FEATURE_NAME"
}
