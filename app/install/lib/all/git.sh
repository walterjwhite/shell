_is_registry_online() {
  warn_on_error=1 time_timeout $conf_install_app_registry_timeout _is_registry_online git ls-remote "$conf_install_app_registry_git_url" HEAD >/dev/null 2>&1
}
