lib ./install/setup.sh

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

    local reinstalled_elements=$(_install_get_reinstalled_elements)
    if [ -n "$reinstalled_elements" ]; then
      uninstall_packages=$(printf '%s' "$uninstall_packages" | $GNU_GREP -Pv "($reinstalled_elements)")
      [ -z "$uninstall_packages" ] && {
        log_warn "uninstall - $setup_type_name - skipping (all will be reinstalled)"
        return 1
      }
    fi
  }

  local element
  for element in $(_install_filter_file $1); do
    log_detail "uninstalling $element"
    $2 $element
  done

  rm -f $1
}

_install_get_reinstalled_elements() {
  local setup_dir="$APP_INSTALL_PATH/setup/$APP_PLATFORM_PLATFORM"
  [ ! -d "$setup_dir" ] && setup_dir="$APP_INSTALL_PATH/setup/all"
  [ ! -d "$setup_dir" ] && return

  local setup_type setup_type_name reinstalled_elements=""

  for setup_type in $(find "$setup_dir" -maxdepth 1 -mindepth 1 2>/dev/null | sort -uV); do
    setup_type_name=$(basename "$setup_type")

    if _setup_type_platform_is_supported "$setup_type_name" &&
      _setup_type_is_supported "$setup_type_name" &&
      ! _setup_type_is_disabled "$setup_type_name"; then

      local normalized_type_name="$setup_type_name"
      case $normalized_type_name in
      *.*)
        normalized_type_name=$(printf '%s' $normalized_type_name | sed -e "s/^.*\.//")
        ;;
      esac
      normalized_type_name=${normalized_type_name%_*}
      normalized_type_name=$(printf '%s' $normalized_type_name | tr '[:upper:]' '[:lower:]')

      [ "$normalized_type_name" = "$setup_type_name" ] && {
        local elements=$($GNU_GREP -Pv '(^$|^#)' "$setup_type" 2>/dev/null | tr '\n' ' ')
        [ -n "$elements" ] && reinstalled_elements="${reinstalled_elements}${elements}|"
      }
    fi
  done

  printf '%s' "$reinstalled_elements" | sed 's/|$//'
}

_install_exclude_contents_from_file() {
  find $REGISTRY_PATH/$target_application_name/$APP_PLATFORM_PLATFORM/setup $APP_LIBRARY_PATH/*/type -type f -name "*$setup_type_name*" \
    -exec $GNU_GREP -Pv '(^$|^#)' {} + 2>/dev/null | tr '\n' '|'
}

_install_setup_type_add() {
  printf "%s\n" "$1" | _install_setup_type_append
}

_install_setup_type_append() {
  mkdir -p "$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type"
  cat - >>"$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type/${setup_type_name}"

  chmod 444 "$APP_PLATFORM_LIBRARY_PATH/$target_application_name/type/${setup_type_name}"
}
