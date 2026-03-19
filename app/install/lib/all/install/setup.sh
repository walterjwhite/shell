_setup_main() {
  local setup_type
  for setup_type in $(find $1 -maxdepth 1 -mindepth 1 2>/dev/null | sort -uV); do
    _setup_run_type "$setup_type"
  done
}

_setup_run_type() {
  setup_type_name=$(basename $1)
  log_add_context "$setup_type_name"
  log_debug "processing"

  _setup_type_platform_is_supported || {
    log_debug "ignoring $1, does not target this sub-platform"
    log_remove_context
    return
  }

  _setup_get_type_name

  _setup_type_is_supported || {
    log_warn "unknown type: $setup_type_name"
    log_remove_context
    return
  }


  _setup_type_is_disabled && {
    log_warn "ignoring, disabled"
    log_remove_context
    return
  }

  _setup_run_do_bootstrap

  log_detail processing

  ${setup_type_name}_install $1 || {
    local error=$?
    log_warn "exit_with_error installing: $error"
    log_remove_context
    return $error
  }

  log_remove_context

  return 0
}

_setup_contains_subtype() {
  [ -z "$APP_PLATFORM_SUB_PLATFORM" ] && return 1

  case $1 in
  *_*)
    return 0
    ;;
  esac

  return 1
}

_setup_sub_platform_matches() {
  local setup_type_sub_platform=${1##*_}

  setup_type_sub_platform=${setup_type_sub_platform%%.*}

  [ -z "$setup_type_sub_platform" ] && return 0

  [ "$setup_type_sub_platform" = "$APP_PLATFORM_SUB_PLATFORM" ] && return 0

  [ -n "$APP_PLATFORM_DERIVED_SUB_PLATFORM" ] && [ "$setup_type_sub_platform" = "$APP_PLATFORM_DERIVED_SUB_PLATFORM" ] && return 0

  return 1
}

_setup_type_platform_is_supported() {
  _setup_contains_subtype $setup_type_name || return 0

  _setup_sub_platform_matches $setup_type_name
}

_setup_get_type_name() {
  case $setup_type_name in
  *.*)
    setup_type_name=$(printf '%s' $setup_type_name | sed -e "s/^.*\.//")
    ;;
  esac

  setup_type_name=${setup_type_name%_*}
  setup_type_name=$(printf '%s' $setup_type_name | tr '[:upper:]' '[:lower:]')
}

_setup_type_is_supported() {
  type ${setup_type_name}_install >/dev/null 2>&1
}

_setup_type_is_disabled() {
  _environment_variable_is_set ${setup_type_name}_disabled
}

_setup_run_do_bootstrap() {
  _setup_type_bootstrapped && return

  log_detail "bootstrapping"
  exec_call ${setup_type_name}_bootstrap
  exec_call ${setup_type_name}_bootstrap_post

  printf '_bootstrap_%s=1\n' "$setup_type_name" | _metadata_install_append
}

_setup_type_bootstrapped() {
  _metadata_install_is_set "_bootstrap_${setup_type_name}"
}

_setup_type_is_installed() {
  find $LIBRARY_PATH -type f -path "*/type/$setup_type_name" -exec $GNU_GREP -Pqm1 "^$1$" {} + 2>/dev/null
}
