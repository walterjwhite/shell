_install_prepare_target() {
  mkdir -p $APP_PLATFORM_LIBRARY_PATH/$target_application_name
}

_install_filter_file() {
  local _setup_file=$1
  $GNU_GREP -Pv '(^$|^#)' $_setup_file | tr '\n' ' '
  unset _setup_file
}

_install_filter_file_callback() {
  local _setup_file=$1
  local _callback=$2
  local element
  for element in $(_install_filter_file $_setup_file); do
    $_callback $element && _install_setup_type_add $element || log_warn "failed to install $element"
  done
  unset _setup_file _callback element
}

_install_uninstall_filter_file_callback() {
  local uninstall_packages=$($GNU_GREP -Pv '(^$|^#)' $_SETUP_TYPE_FILE | tr '\n' ' ')
  if [ -z "$uninstall_packages" ]; then
    log_debug "no ${setup_type_name}(s) to uninstall"
    return
  fi

  [ -n "$_INSTALL" ] && {
    local packages_to_install=$(_install_exclude_contents_from_file)

    uninstall_packages=$(printf '%s' "$uninstall_packages" | $GNU_GREP -Pv "($packages_to_install)")
    [ -z "$uninstall_packages" ] && {
      log_warn "uninstall - $setup_type_name - skipping"
      return 1
    }
  }

  local element
  for element in $(_install_filter_file $1); do
    $2 $element
  done

  rm -f $1
}

_install_exclude_contents_from_file() {
  find $REGISTRY_PATH/$target_application_name/$APP_PLATFORM_PLATFORM/setup $APP_LIBRARY_PATH/*/type -type f -name "*$setup_type_name*" \
    -exec $GNU_GREP -Pv '(^$|^#)' {} + 2>/dev/null | tr '\n' '|'
}

_install_setup_type_add() {
  printf "%s\n" "$1" | _install_setup_type_write
}

_install_setup_type_write() {
  mkdir -p "$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type"
  cat - >>"$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type/${setup_type_name}"

  chmod 444 "$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type/${setup_type_name}"
}
