_configure_configure() {
  log_info "configuring system"
  cd $conf_os_installer_system_workspace

  _configure_system
  _configure_patches
}

_configure_system() {
  log_info "configuring system/conf"
  [ -e system/conf ] && {
    _import_conf system/conf
  }

  local import_file
  for import_file in $(find imports -type f -path '*/system/conf'); do
    _import_conf "$import_file"
  done
}

_import_conf() {
  log_debug "importing $1"
  . $1
}

_configure_patches() {
  log_debug "configuring patches - $PWD"

  local configuration_script patch_path
  for configuration_script in $(find patches imports -type f -path '*.patch/configure'); do
    patch_path=$(dirname $configuration_script)

    log_debug "evaluating $patch_path"

    . $configuration_script || {
      log_debug "$configuration_script [$?], disabling patch"
      rm -rf $patch_path

      continue
    }

    log_debug "keeping $patch_path"
  done
}
