patch_run() {
  _module_find_callback _run_do
}

_run_do() {
  cd $conf_os_installer_system_workspace
  . $1
}
