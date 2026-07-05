_app_build() {
  project_root=$(git rev-parse --show-toplevel)
  _settings_init

  if [ ! -e .app ]; then
    log_warn "no .app file found, attempting to build apps recursively"
    _app_build_recursive
    return
  fi

  _app_build_instance
}

_app_build_recursive() {
  local app
  local build_wd=$PWD
  local _requested_build_platforms="$build_platforms"
  local _requested_build_all_platforms="$build_all_platforms"
  find . -maxdepth "$conf_install_app_build_depth" -type f ! -path '*/.*/*' -name .app |
    sed -e 's/\.app$//' | sort -u |
    while IFS= read -r app; do
      cd "$app" || {
        log_warn "cannot cd to $app"
        continue
      }
      build_platforms="$_requested_build_platforms"
      build_all_platforms="$_requested_build_all_platforms"
      _app_build_instance
      cd "$build_wd" || exit_with_error "cannot return to build working directory: $build_wd"
    done
}

_app_build_instance() {
  target_application_name=$(basename "$PWD")
  log_add_context "$target_application_name"

  log_info "building"

  mkdir -p "$ARTIFACTS_BUILD_PATH/$target_application_name"

  _app_build_settings

  _app_build_determine_build_platforms
  _app_build_platforms

  log_remove_context
}

#
#
_app_build_settings() {
  unset install_target
  unset INSTALL_TARGET
  unset TARGET_PLATFORM_PATH TARGET_BIN_PATH TARGET_SBIN_PATH
  unset TARGET_APP_PLATFORM_PATH TARGET_APP_PLATFORM_BIN_PATH TARGET_APP_PLATFORM_SBIN_PATH
  unset TARGET_APP_PLATFORM_CACHE_PATH TARGET_APP_PLATFORM_CONFIG_PATH
  unset TARGET_APP_CONFIG_PATH TARGET_APP_PATH TARGET_APP_PLATFORM_EXTENSIONS_PATH
  unset TARGET_PLATFORM_SYSTEM_ID_PATH

  . ./.app

  INSTALL_TARGET="${install_target:-USER}"

  case $INSTALL_TARGET in
  SYSTEM)
    TARGET_PLATFORM_PATH=/usr/local/walterjwhite
    TARGET_BIN_PATH=/usr/local/bin
    TARGET_SBIN_PATH=/usr/local/sbin

    TARGET_PLATFORM_SYSTEM_ID_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/usr/local/etc/walterjwhite/system)
    TARGET_APP_PLATFORM_CACHE_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/var/cache/walterjwhite/shell)
    TARGET_APP_PLATFORM_CONFIG_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/usr/local/etc/walterjwhite/shell)
    TARGET_APP_PLATFORM_BIN_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/${TARGET_BIN_PATH})
    TARGET_APP_PLATFORM_SBIN_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/${TARGET_SBIN_PATH})
    TARGET_APP_PLATFORM_PATH=$(realpath -m ${APP_PLATFORM_ROOT}/${TARGET_PLATFORM_PATH})
    TARGET_APP_CONFIG_PATH=${TARGET_APP_PLATFORM_CONFIG_PATH}/${target_application_name}
    TARGET_APP_PATH=${TARGET_APP_PLATFORM_PATH}/apps/${target_application_name}
    TARGET_APP_PLATFORM_EXTENSIONS_PATH=${TARGET_APP_PLATFORM_PATH}/extensions
    ;;
  USER | *)
    TARGET_PLATFORM_PATH='$HOME/.local/walterjwhite'
    TARGET_BIN_PATH='$HOME/.local/bin'

    TARGET_PLATFORM_SYSTEM_ID_PATH='$HOME/.local/etc/walterjwhite/system'
    TARGET_APP_PLATFORM_CACHE_PATH='$HOME/.cache'
    TARGET_APP_PLATFORM_CONFIG_PATH='$HOME/.config/walterjwhite/shell'
    TARGET_APP_PLATFORM_BIN_PATH='$HOME/.local/bin'
    TARGET_APP_PLATFORM_PATH='$HOME/.local/walterjwhite'
    TARGET_APP_CONFIG_PATH='$HOME/.config/walterjwhite/shell/'"${target_application_name}"
    TARGET_APP_PATH='$HOME/.local/walterjwhite/apps/'"${target_application_name}"
    TARGET_APP_PLATFORM_EXTENSIONS_PATH='$HOME/.local/walterjwhite/extensions'
    ;;
  esac
}
