#!/bin/sh

#


_stub_log_output=""

log_info() { _stub_log_output="${_stub_log_output}INF $*\n"; }
log_warn() { _stub_log_output="${_stub_log_output}WRN $*\n"; }
log_detail() { _stub_log_output="${_stub_log_output}DTL $*\n"; }
log_debug() { _stub_log_output="${_stub_log_output}DBG $*\n"; }

stub_log_reset() {
  _stub_log_output=""
}


_stub_exit_error=""

exit_with_error() {
  _stub_exit_error="$1"
  return 1
}

stub_exit_reset() {
  _stub_exit_error=""
}


validation_require() {
  [ -n "$1" ] && return 0
  exit_with_error "$2 required"
}


exec_call() {
  local _fn="$1"
  shift
  type "$_fn" >/dev/null 2>&1 || {
    log_debug "${_fn} does not exist"
    return 255
  }
  "$_fn" "$@"
}


_mktemp_mktemp() {
  mktemp
}

_file_has_contents() {
  [ -s "$1" ]
}

file_require() {
  [ -f "$1" ] || exit_with_error "file required: $1"
}


_stub_type_tracking=""

_install_setup_type_append() {
  local _content
  _content=$(cat -)
  _stub_type_tracking="${_stub_type_tracking}${_content}\n"
}

stub_tracking_reset() {
  _stub_type_tracking=""
}


APP_PLATFORM_PLATFORM="${APP_PLATFORM_PLATFORM:-Linux}"
APP_PLATFORM_ARCHITECTURE="${APP_PLATFORM_ARCHITECTURE:-x86_64}"
GNU_GREP="${GNU_GREP:-grep}"
GNU_SED="${GNU_SED:-sed}"
TAR_ARGS="${TAR_ARGS:- -f - }"


setup_target_paths() {
  local _base="${1:-/tmp/test_target_$$}"
  TARGET_INSTALL_USER="${TARGET_INSTALL_USER:-USER}"
  TARGET_APP_PATH="$_base/apps/testapp"
  TARGET_APP_PLATFORM_PATH="$_base"
  TARGET_APP_PLATFORM_BIN_PATH="$_base/bin"
  TARGET_APP_PLATFORM_SBIN_PATH="$_base/sbin"
  TARGET_APP_PLATFORM_CONFIG_PATH="$_base/config"
  TARGET_APP_PLATFORM_CACHE_PATH="$_base/cache"
  TARGET_APP_CONFIG_PATH="$_base/config/testapp"
  TARGET_APP_PLATFORM_EXTENSIONS_PATH="$_base/extensions"
  TARGET_PLATFORM_SYSTEM_ID_PATH="$_base/system"
  TARGET_BIN_PATH="$_base/bin"
  target_application_name="testapp"
  setup_type_name="bin"
}

teardown_target_paths() {
  local _base="${1:-/tmp/test_target_$$}"
  rm -rf "$_base"
  unset TARGET_INSTALL_USER TARGET_APP_PATH TARGET_APP_PLATFORM_PATH
  unset TARGET_APP_PLATFORM_BIN_PATH TARGET_APP_PLATFORM_SBIN_PATH
  unset TARGET_APP_PLATFORM_CONFIG_PATH TARGET_APP_PLATFORM_CACHE_PATH
  unset TARGET_APP_CONFIG_PATH TARGET_APP_PLATFORM_EXTENSIONS_PATH
  unset TARGET_PLATFORM_SYSTEM_ID_PATH TARGET_BIN_PATH
  unset target_application_name setup_type_name
}


make_fixture_app() {
  local _dir="$1" _install_user="${2:-USER}"
  mkdir -p "$_dir/Linux/setup/bin"
  mkdir -p "$_dir/Linux/setup/package"
  printf 'install_user=%s\n' "$_install_user" >"$_dir/.app"
  printf '#!/bin/sh\necho hello\n' >"$_dir/Linux/setup/bin/mybin"
  printf 'jq\ncurl\n' >"$_dir/Linux/setup/package/packages"
}
