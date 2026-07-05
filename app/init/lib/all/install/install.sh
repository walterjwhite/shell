lib ./install/setup.sh

_install_prepare_target() {
  mkdir -p "$TARGET_APP_PATH"
}

_install_filter_file() {
  local _setup_file=$1
  $GNU_GREP -Pv '(^$|^#)' "$_setup_file" | tr '\n' ' '
  unset _setup_file
}

_install_filter_file_callback() {
  local _setup_file=$1
  local _callback=$2
  local element
  for element in $(_install_filter_file "$_setup_file"); do
    if "$_callback" "$element"; then
      _install_setup_type_add "$element"
    else
      log_warn "failed to install $element"
    fi
  done
  unset _setup_file _callback element
}

_install_uninstall_filter_file_callback() {
  local setup_file_type="$1"
  local uninstall_packages
  uninstall_packages=$($GNU_GREP -Pv '(^$|^#)' "$setup_file_type" | tr '\n' ' ')
  if [ -z "$uninstall_packages" ]; then
    log_debug "no ${setup_type_name}(s) to uninstall"
    return
  fi

  [ -n "$_APP_INSTALLATION" ] && {
    local packages_to_install
    packages_to_install=$(_install_exclude_contents_from_file)

    uninstall_packages=$(printf '%s' "$uninstall_packages" | $GNU_GREP -Pv "($packages_to_install)")
    [ -z "$uninstall_packages" ] && {
      log_warn "uninstall - $setup_type_name - skipping"
      return 1
    }

    local reinstalled_elements
    reinstalled_elements=$(_install_get_reinstalled_elements)
    if [ -n "$reinstalled_elements" ]; then
      uninstall_packages=$(printf '%s' "$uninstall_packages" | $GNU_GREP -Pv "($reinstalled_elements)")
      [ -z "$uninstall_packages" ] && {
        log_warn "uninstall - $setup_type_name - skipping (all will be reinstalled)"
        return 1
      }
    fi
  }

  local element
  for element in $uninstall_packages; do
    log_detail "uninstalling $element"
    "$2" "$element"
  done

  rm -f "$1"
}

_install_get_reinstalled_elements() {
  local _app_install_path="$registry_path/$target_application_name"
  local setup_dir="$_app_install_path/setup/$target_platform"
  [ ! -d "$setup_dir" ] && setup_dir="$_app_install_path/setup/all"
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
        normalized_type_name=$(printf '%s' "$normalized_type_name" | sed -e "s/^.*\\.//")
        ;;
      esac
      normalized_type_name=${normalized_type_name%_*}
      normalized_type_name=$(printf '%s' "$normalized_type_name" | tr '[:upper:]' '[:lower:]')

      [ "$normalized_type_name" = "$setup_type_name" ] && {
        local elements
        elements=$($GNU_GREP -Pv '(^$|^#)' "$setup_type" 2>/dev/null | tr '\n' ' ')
        [ -n "$elements" ] && reinstalled_elements="${reinstalled_elements}${elements}|"
      }
    fi
  done

  printf '%s' "$reinstalled_elements" | sed 's/|$//'
}

_install_exclude_contents_from_file() {
  $GNU_GREP -Pvh '(^$|^#)' "$TARGET_APP_PATH/type/$setup_type_name" 2>/dev/null | tr '\n' '|'
}

_install_setup_type_add() {
  printf "%s\n" "$1" | _install_setup_type_append
}

_install_setup_type_append() {
  mkdir -p "$TARGET_APP_PATH/type"
  cat - >>"$TARGET_APP_PATH/type/${setup_type_name}"
}
