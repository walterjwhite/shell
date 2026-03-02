_provider_run_all() {
  _provider_run_wrapper _provider_run_all_callback "$@"
}

_provider_run_wrapper() {
  [ $provider_import_path ] || provider_import_path=$APP_LIBRARY_PATH/provider
  [ ! -e $provider_import_path ] && return 1

  local callback_function=$1
  shift

  application_name_prefix=$(printf '%s' $APPLICATION_NAME | tr '-' '_' | tr '.' '_')
  log_add_context $application_name_prefix
 
  $callback_function "$@"

  log_remove_context
}

_provider_run_all_callback() {
  for provider in $(find $provider_import_path -type f | sort -V); do
    _provider_run "$@"
  done
}

_provider_run() {
  provider_name=$(basename $provider | sed -e 's/\.sh$//')
  provider_function_name=$(printf '%s' $provider_name | tr '-' '_' | tr '.' '_')

  log_add_context $provider_name

  exec_call ${application_name_prefix}_before_each

  . $provider

  if [ "$#" -eq 0 ]; then
    ${application_name_prefix}_${provider_function_name}${provider_function_suffix}
  else
    [ -n "$1" ] && $1
    [ -n "$2" ] && $2
  fi

  exec_call ${application_name_prefix}_after_each

  log_remove_context
  unset provider_name provider_function_name
}

_provider_run_all_named() {
  local callback_function=$1
  shift

  for provider_name in "$@"; do
    _provider_run_named $callback_function $provider_name
  done
}

_provider_run_named() {
  _provider_run_wrapper _provider_run_named_callback "$@"
}

_provider_run_named_callback() {
  provider=$(find $provider_import_path -type f -name "$2.sh" -print -quit)
  file_require "$provider" "provider"

  _provider_run "$1"
}

_provider_load() {
  [ $# -lt 1 ] && exit_with_error "provider name is required, ie. firefox"

  local _provider_name=$1
  shift

  [ $provider_import_path ] || provider_import_path=$APP_LIBRARY_PATH/provider

  local provider_file=$(find $provider_import_path -type f -name "$_provider_name.sh" | head -1)
  _include_optional $provider_file || exit_with_error "unable to load $provider_file | $provider_import_path"
}
