_bootstrap_install() {
  log_detail "bootstrapping install"

  setup_type_name=package _setup_run_do_bootstrap

  if [ -n "$PLATFORM_PACKAGES" ]; then
    _package_install_new_only $PLATFORM_PACKAGES
  else
    log_detail "no PLATFORM_PACKAGES defined for this platform, skipping bootstrap package install"
  fi
}
