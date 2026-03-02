_bootstrap_install() {
  log_detail "bootstrapping install"

  setup_type_name=package _setup_run_do_bootstrap
  _package_install_new_only $PLATFORM_PACKAGES
}
