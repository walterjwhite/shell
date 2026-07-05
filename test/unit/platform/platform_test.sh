#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

. "$SCRIPT_DIR/../../../lib/all/platform.sh"

describe "platform_is_supported"

test "current platform in supported list passes" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Linux
  platform_is_supported "FreeBSD Linux Apple"
  assert_empty "$_stub_exit_error" "Linux accepted in multi-platform list"
'

test "current platform not in supported list fails" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Linux
  platform_is_supported "FreeBSD Apple"
  assert_not_empty "$_stub_exit_error" \
    "Linux rejected when not in supported list"
  assert_contains "FreeBSD Apple" "$_stub_exit_error" \
    "error lists supported platforms"
'

test "single-platform match passes" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=FreeBSD
  platform_is_supported "FreeBSD"
  assert_empty "$_stub_exit_error" "exact single match passes"
'

test "empty argument accepts all platforms" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Linux
  platform_is_supported ""
  assert_empty "$_stub_exit_error" "empty arg is permissive"
'

test "no argument accepts all platforms" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Windows
  platform_is_supported
  assert_empty "$_stub_exit_error" "no arg is permissive"
'

test "partial name is not a match" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Lin
  platform_is_supported "Linux"
  assert_not_empty "$_stub_exit_error" \
    "partial platform name does not match"
'

run_tests
