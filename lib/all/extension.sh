lib feature.sh
lib io/file.sh

_extension_main() {
  extension_action=$APPLICATION_CMD

  required_message="$extension_action is not yet implemented by any extensions" file_require "__LIBRARY_PATH__/install/extensions/extension/$extension_action"

  extension_opwd=$PWD

  local _error_count=0
  for extension_run_type_path in $(find __LIBRARY_PATH__/install/extensions/extension/$extension_action -mindepth 1 -maxdepth 1 -type d | sort -V); do
    extension_run_type=$(basename $extension_run_type_path | sed 's/^[[:digit:]]\{2\}\.//')
    extension_run_type="${extension_run_type#*.}"

    log_add_context $extension_run_type

    _extension_is_run_type || {
      log_debug "skipping $extension_run_type"
      log_remove_context

      continue
    }

    extension_feature_name=${extension_action}_${extension_run_type}
    extension_run_type_name=$(printf '%s' $extension_run_type | tr '-' '_')

    _is_feature_enabled $extension_feature_name || {
      log_debug "skipping feature: $extension_feature_name | $extension_run_type - disabled"
      unset extension_feature_name
      log_remove_context

      continue
    }

    _extension_load_type

    _extension_is_runnable || {
      log_debug "skipping $extension_run_type, no files"
      log_remove_context

      continue
    }

    log_detail "$extension_action [$extension_run_type]"

    _extension_run "$@" || _error_count=$(($_error_count + 1))

    log_remove_context

    [ -n "$fail_fast" ] && [ $_error_count -gt 0 ] && exit_with_error "$extension_run_type failed with $_error_count error(s)"

    cd $extension_opwd
  done

  [ $_error_count -gt 0 ] && exit_with_error "encountered $_error_count error(s), check logs for errors"
}

_extension_is_run_type() {
  [ -z "$types" ] && return 0

  local _run_type
  for _run_type in $types; do
    [ "$_run_type" = "$extension_run_type" ] && return 0
  done

  return 1
}

_extension_is_runnable() {
  exec_call ${extension_run_type}_is_runnable || {
    [ $? -eq 255 ] && {
      _extension_is_runnable_default
    }
  }
}

_extension_is_runnable_default() {
  _extension_find_default -print -quit | grep -cqm1 '.'
}

_extension_find_default() {
  local _name_pattern=$(set | $GNU_GREP -P "^${extension_run_type}_name_pattern=" | sed -e "s/^${extension_run_type}_name_pattern=//")
  [ -z "$_name_pattern" ] && {
    case $extension_run_type in
    [a-z][a-z] | [a-z][a-z][a-z] | [a-z][a-z][a-z][a-z])
      _name_pattern="*.$extension_run_type"
      ;;
    *)
      _name_pattern=$extension_run_type
      ;;
    esac
  }

  _extension_find_default_files "$@"
}

_extension_find_default_files() {
  find . -type f -and -name "$_name_pattern" \
    ! -path '*/*.archived/*' \
    ! -path '*/*.secret/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/target/*' \
    ! -path '*/.idea/*' \
    ! -path '*/.git/*' "$@"
}

extension_find_dirs_containing() {
  _extension_find_default -exec dirname {} \; | sort -uV
}

_extension_load_type() {
  [ -e __LIBRARY_PATH__/install/extensions/type/$extension_run_type.sh ] && {
    . __LIBRARY_PATH__/install/extensions/type/$extension_run_type.sh
    cd $extension_opwd
  }
}

_extension_run() {
  local _error_count=0
  [ ! -e $extension_run_type_path ] && return

  for extension_executor in $(find $extension_run_type_path -mindepth 1 -maxdepth 1 -type f ! -name '.*' 2>/dev/null | sort -V); do
    extension_sub_feature_name=${extension_feature_name}_$(basename $extension_executor | tr '-' '_' | sed -e "s/\..*$//")
    _is_feature_enabled $extension_sub_feature_name || {
      unset exec_cmd extension_sub_feature_name
      continue
    }

    log_add_context $extension_sub_feature_name
    log_detail $extension_sub_feature_name

    cd $extension_opwd

    . $extension_executor || _error_count=$(($_error_count + 1))

    log_remove_context
    [ -n "$fail_fast" ] && [ $_error_count -gt 0 ] && exit_with_error "$extension_run_type failed with $_error_count error(s)"
  done

  return $_error_count
}
