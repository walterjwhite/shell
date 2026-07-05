lib io/file.sh

_patches_patches() {
  for module in $@; do
    _module_set_log || {
      log_warn "$module already run, skipping"
      continue
    }

    required_message="$conf_os_installer_system_workspace - Configuration directory does not exist" file_require "$conf_os_installer_system_workspace"

    _module_run_build

    log_remove_context
  done
}

_module_set_log() {
  [ -z "$_index" ] && _index=0

  local module_logfile="/var/log/walterjwhite/${_index}.build.${module}"
  _index=$((_index + 1))
  [ -e $module_logfile ] && {
    return 1
  }

  _log_set_logfile $module_logfile
  log_add_context $module
}

_module_run_build() {
  cd $conf_os_installer_system_workspace

  eval "module_exec=\${${module}_exec}"
  eval "module_type=\${${module}_type}"
  eval "module_path=\${${module}_path}"
  eval "module_debug=\${${module}_debug}"

  [ -z "$module_type" ] && module_type=f
  [ -z "$module_path" ] && module_path="$module/*"

  [ -n "$module_debug" ] && set -x

  if [ $(_module_find -print -quit | wc -l) -eq 0 ]; then
    [ -n "$module_debug" ] && set +x

    log_info "no patches found - $module_type $module_path"
    unset module_exec module_type module_path module_debug

    return
  fi

  log_detail "start"

  patch_$module || {
    module_status=$?
    log_warn "module debug: $module_exec | $module_type | $module_path"
  }

  [ -n "$module_debug" ] && set +x

  _module_log_status $module $module_status
  unset module_exec module_type module_path module_debug
}

_platform_suffix() {
  if [ -n "$APP_PLATFORM_SUB_PLATFORM" ]; then
    printf '_%s_%s' "$APP_PLATFORM_PLATFORM" "$APP_PLATFORM_SUB_PLATFORM"
  else
    printf '_%s' "$APP_PLATFORM_PLATFORM"
  fi
}

_module_find() {
  local patch_path=physical
  [ -n "$_in_container" ] && patch_path=container

  local suffix
  suffix=$(_platform_suffix)

  find . -type "$module_type" ! -path '*/.archived/*' \
    -and \( -path '*/patches/any/*' -or -path "*/patches/$patch_path/*" \) \
    -and \( \
    -path "*/*.patch/${module_path}" \
    -or -path "*/*.patch${suffix}/${module_path}" \
    -or -path "*/*.patch/${module_path}${suffix}" \
    \) "$@" 2>/dev/null
}

_module_find_callback() {
  local element
  for element in $(_module_find); do
    log_add_context "$element"
    $1 "$element"
    log_remove_context
  done
}

_module_find_filtered() {
  _module_find -exec $GNU_GREP -Pvh '(^#|^$)' {} + | sort -V | tr '\n' ' ' | sed -e 's/ $/\n/'
}

_module_find_filtered_callback() {
  local element
  for element in $(_module_find_filtered); do
    log_add_context "$element"
    log_detail "start"
    $1 "$element" && log_detail "end - success" || {
      log_warn "end - error: $?"
    }

    log_remove_context
  done
}

_module_log_status() {
  if [ -n "$2" ]; then
    log_warn "end - exit_with_error ($2)"
  else
    log_detail "end - success"
  fi
}

_module_get_patch_name() {
  _module_get_patch_path "$1" |
    sed -e "s/^\.\///" -e "s/\.patch$//" -e "s/^patches\///"
}

_module_get_patch_path() {
  printf '%s' "$1" | $GNU_GREP -Po '^.*.\.patch'
}
