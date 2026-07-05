#!/bin/sh

#
#
#
#
#

DRY_RUN_MODE="${DRY_RUN_MODE:-record}"
dry_run_log=""
_dry_run_active=0


_dry_record() {
  local _entry
  _entry=$(printf '%s' "$*")
  if [ -z "$dry_run_log" ]; then
    dry_run_log="$_entry"
  else
    dry_run_log="${dry_run_log}
${_entry}"
  fi
}

_dry_dispatch() {
  _dry_record "$@"
  case "$DRY_RUN_MODE" in
  passthrough) command "$@" ;;
  *) return 0 ;;
  esac
}


_dry_shims_mkdir() { _dry_dispatch mkdir "$@"; }
_dry_shims_rm() { _dry_dispatch rm "$@"; }
_dry_shims_cp() { _dry_dispatch cp "$@"; }
_dry_shims_chmod() { _dry_dispatch chmod "$@"; }
_dry_shims_ln() { _dry_dispatch ln "$@"; }
_dry_shims_tar() { _dry_dispatch tar "$@"; }
_dry_shims_curl() { _dry_dispatch curl "$@"; }
_dry_shims_npm() { _dry_dispatch npm "$@"; }
_dry_shims_pip() { _dry_dispatch pip "$@"; }
_dry_shims_cargo() { _dry_dispatch cargo "$@"; }
_dry_shims_go() { _dry_dispatch go "$@"; }
_dry_shims_crontab() { _dry_dispatch crontab "$@"; }
_dry_shims_sudo_run() {
  _dry_record "sudo_run $*"
  return 0
}


dry_run_enable() {
  [ "$_dry_run_active" -eq 1 ] && return 0
  _dry_run_active=1
  dry_run_log=""
  mkdir() { _dry_shims_mkdir "$@"; }
  rm() { _dry_shims_rm "$@"; }
  cp() { _dry_shims_cp "$@"; }
  chmod() { _dry_shims_chmod "$@"; }
  ln() { _dry_shims_ln "$@"; }
  tar() { _dry_shims_tar "$@"; }
  curl() { _dry_shims_curl "$@"; }
  npm() { _dry_shims_npm "$@"; }
  pip() { _dry_shims_pip "$@"; }
  cargo() { _dry_shims_cargo "$@"; }
  go() { _dry_shims_go "$@"; }
  crontab() { _dry_shims_crontab "$@"; }
  sudo_run() { _dry_shims_sudo_run "$@"; }
}

dry_run_disable() {
  [ "$_dry_run_active" -eq 0 ] && return 0
  _dry_run_active=0
  unset -f mkdir rm cp chmod ln tar curl npm pip cargo go crontab sudo_run \
    2>/dev/null || true
}

dry_run_reset() {
  dry_run_log=""
}


with_dry_run() {
  dry_run_enable
  dry_run_reset
  set +e
  eval "$1"
  set -e
  dry_run_disable
}

dry_run_real() {
  command "$@"
}
