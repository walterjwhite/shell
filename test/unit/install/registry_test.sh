#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

. "$SCRIPT_DIR/../../../app/init/lib/all/git.sh"
. "$SCRIPT_DIR/../../../app/init/lib/all/install/git.sh"

describe "_set_registry"

test "defaults to the configured default registry" '
  stub_exit_reset
  stub_log_reset
  unset use_registry registry_name registry_url registry_path
  REGISTRY_PATH=/tmp/registries_$$
  conf_init_app_registries="default|https://github.com/example/default.git,secondary|https://github.com/example/secondary.git"
  _set_registry
  assert_eq "default" "$registry_name" "default registry name selected"
  assert_eq "https://github.com/example/default.git" "$registry_url" \
    "default registry url selected"
  assert_eq "/tmp/registries_$$/default" "$registry_path" \
    "default registry path uses registry name"
'

test "selects the requested registry at runtime" '
  stub_exit_reset
  stub_log_reset
  use_registry=secondary
  REGISTRY_PATH=/tmp/registries_$$
  conf_init_app_registries="default|https://github.com/example/default.git, secondary | https://github.com/example/secondary.git"
  _set_registry
  assert_eq "secondary" "$registry_name" "requested registry name selected"
  assert_eq "https://github.com/example/secondary.git" "$registry_url" \
    "requested registry url selected"
  assert_eq "/tmp/registries_$$/secondary" "$registry_path" \
    "requested registry path uses registry name"
  unset use_registry
'

test "fails when requested registry is missing" '
  stub_exit_reset
  stub_log_reset
  use_registry=missing
  REGISTRY_PATH=/tmp/registries_$$
  conf_init_app_registries="default|https://github.com/example/default.git"
  _set_registry
  assert_not_empty "$_stub_exit_error" "missing registry triggers error"
  assert_contains "missing" "$_stub_exit_error" "missing registry named in error"
  unset use_registry
'

describe "_git_local_repository_version"

test "uses the selected registry path" '
  _git_call_file=$(mktemp)
  git() {
    printf "%s\n" "$*" >> "$_git_call_file"
    case "$1" in
    --git-dir=/tmp/registries_$$/secondary/.git)
      printf "abc1234\n"
      ;;
    *)
      return 1
      ;;
    esac
  }

  registry_path=/tmp/registries_$$/secondary
  result=$(_git_local_repository_version)
  assert_eq "abc1234" "$result" "local registry version returned"
  _git_call_contents=$(cat "$_git_call_file")
  assert_contains "--git-dir=/tmp/registries_$$/secondary/.git" "$_git_call_contents" \
    "git called with selected registry path"
  rm -f "$_git_call_file"
  unset -f git
'

run_tests
