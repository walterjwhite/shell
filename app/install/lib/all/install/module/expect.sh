expect_bootstrap() {
  _expect_bootstrap_is_expect_available || {
    _package_install_new_only $EXPECT_PACKAGE
    _expect_bootstrap_is_expect_available || EXPECT_DISABLED=1
  }
}

_expect_bootstrap_is_expect_available() {
  which expect >/dev/null 2>&1
}

expect_install() {
  $1 >/dev/null 2>&1
}
