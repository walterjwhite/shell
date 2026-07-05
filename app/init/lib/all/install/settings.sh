_settings_init() {
  log_info "using root directory: $APP_PLATFORM_ROOT"

  _include_optional "$APPLICATION_METADATA_PATH"

  if [ "$APP_PLATFORM_ROOT" != "/" ]; then
    log_warn "using alternate root: $APP_PLATFORM_ROOT"
    unset $(set | tr '\0' '\n' | grep '^bootstrap_[a-z0-9_]*=' | sed -e 's/=.*$//' | tr '\n' ' ')
  fi

  if [ -z "$target_platform" ]; then
    target_platform=$APP_PLATFORM_PLATFORM
  else
    log_warn "targeting $target_platform on $APP_PLATFORM_PLATFORM"
  fi
}

_settings_application() {
  target_application_install_date=$(date +"%a %b %d %H:%M:%S %Y %z")

  unset install_target INSTALL_TARGET
  [ -f "$registry_path/$target_application_name/.app" ] &&
    . "$registry_path/$target_application_name/.app"
  INSTALL_TARGET="${install_target:-USER}"

  #
  #
  #
  if [ -n "$INSTALL_TARGET_OVERRIDE" ]; then
    case "$INSTALL_TARGET_OVERRIDE" in
    SYSTEM | USER)
      if [ "$INSTALL_TARGET_OVERRIDE" != "$INSTALL_TARGET" ]; then
        log_warn "overriding install_target: registry='$INSTALL_TARGET' -> override='$INSTALL_TARGET_OVERRIDE'"
        INSTALL_TARGET="$INSTALL_TARGET_OVERRIDE"
      fi
      ;;
    *)
      exit_with_error "invalid INSTALL_TARGET_OVERRIDE value '$INSTALL_TARGET_OVERRIDE' — must be SYSTEM or USER"
      ;;
    esac
    export INSTALL_TARGET_OVERRIDE
  fi

  export INSTALL_TARGET

  _settings_validate_install_target
  _settings_resolve_target_paths

  mkdir -p "$TARGET_APP_PATH" "$APP_DATA_PATH/install"

  _include_optional "$target_application_name"
}

#
#
_settings_validate_install_target() {
  case $INSTALL_TARGET in
  SYSTEM)
    sudo_ensure_root $target_application_name
    ;;
  USER | *)
    sudo_ensure_non_root_user $target_application_name
    ;;
  esac
}

#
_settings_resolve_target_paths() {
  local _root=""
  [ "$APP_PLATFORM_ROOT" != "/" ] && _root=$(realpath -m "$APP_PLATFORM_ROOT")

  unset TARGET_PLATFORM_PATH TARGET_BIN_PATH TARGET_SBIN_PATH
  unset TARGET_APP_PLATFORM_PATH TARGET_APP_PLATFORM_BIN_PATH TARGET_APP_PLATFORM_SBIN_PATH
  unset TARGET_APP_PLATFORM_CACHE_PATH TARGET_APP_PLATFORM_CONFIG_PATH
  unset TARGET_APP_CONFIG_PATH TARGET_APP_PATH TARGET_APP_PLATFORM_EXTENSIONS_PATH
  unset TARGET_PLATFORM_SYSTEM_ID_PATH

  case $INSTALL_TARGET in
  SYSTEM)
    TARGET_PLATFORM_PATH=/usr/local/walterjwhite
    TARGET_BIN_PATH=/usr/local/bin
    TARGET_SBIN_PATH=/usr/local/sbin
    TARGET_APP_PLATFORM_PATH=${_root}$TARGET_PLATFORM_PATH
    TARGET_APP_PLATFORM_BIN_PATH=${_root}$TARGET_BIN_PATH
    TARGET_APP_PLATFORM_SBIN_PATH=${_root}$TARGET_SBIN_PATH
    TARGET_APP_PLATFORM_CONFIG_PATH=${_root}/usr/local/etc/walterjwhite/shell
    TARGET_APP_PLATFORM_CACHE_PATH=${_root}/var/cache/walterjwhite/shell
    TARGET_APP_PLATFORM_EXTENSIONS_PATH=${_root}$TARGET_PLATFORM_PATH/extensions
    TARGET_PLATFORM_SYSTEM_ID_PATH=${_root}/usr/local/etc/walterjwhite/system
    TARGET_APP_PATH=${_root}${TARGET_PLATFORM_PATH}/apps/${target_application_name}
    TARGET_APP_CONFIG_PATH=${_root}/usr/local/etc/walterjwhite/shell/${target_application_name}
    ;;
  USER | *)
    TARGET_PLATFORM_PATH=${HOME}/.local/walterjwhite
    TARGET_BIN_PATH=${HOME}/.local/bin
    TARGET_APP_PLATFORM_PATH=${_root}$TARGET_PLATFORM_PATH
    TARGET_APP_PLATFORM_BIN_PATH=${_root}$TARGET_BIN_PATH
    TARGET_APP_PLATFORM_CONFIG_PATH=${_root}${HOME}/.config/walterjwhite/shell
    TARGET_APP_PLATFORM_CACHE_PATH=${_root}${HOME}/.cache
    TARGET_APP_PLATFORM_EXTENSIONS_PATH=${_root}${HOME}/.local/walterjwhite/extensions
    TARGET_PLATFORM_SYSTEM_ID_PATH=${_root}${HOME}/.local/walterjwhite/system
    TARGET_APP_PATH=${_root}${HOME}/.local/walterjwhite/apps/${target_application_name}
    TARGET_APP_CONFIG_PATH=${_root}${HOME}/.config/walterjwhite/shell/${target_application_name}
    ;;
  esac

  validation_require "$TARGET_APP_PATH" "TARGET_APP_PATH - _settings_resolve_target_paths"
  validation_require "$TARGET_APP_PLATFORM_BIN_PATH" "TARGET_APP_PLATFORM_BIN_PATH - _settings_resolve_target_paths"

  #
  #
  if [ "${INSTALL_TARGET:-USER}" = "SYSTEM" ]; then
    conf_install_go_path=/usr/local
  else
    conf_install_go_path=$HOME/.local
  fi
}

_settings_application_defaults() {
  local default_file
  for default_file in $(find "$1/cfg" -type f 2>/dev/null); do
    [ -f "$default_file" ] && . "$default_file"
  done
}
