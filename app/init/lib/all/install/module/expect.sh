expect_bootstrap() {
  _expect_bootstrap_is_expect_available || {
    _package_install_new_only $EXPECT_PACKAGE
    _expect_bootstrap_is_expect_available || EXPECT_DISABLED=1
  }
}

_expect_bootstrap_is_expect_available() {
  command -v expect >/dev/null 2>&1
}

expect_install() {
  local _script
  find "$1" -type f -name '*.exp' | sort | while IFS= read -r _script; do
    log_detail "running expect script: $_script"
    expect "$_script" >/dev/null 2>&1 || log_warn "expect script failed: $_script"
  done
}

expect_is_installed() {
  :
}

expect_is_latest() {
  :
}
