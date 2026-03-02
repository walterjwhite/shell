_system_main() {
  system_locale_${distribution_function_name}

  [ -z "$_in_container" ] && time_synchronization_${distribution_function_name}

  system_pre_${distribution_function_name}

  if [ -z "$_in_container" ]; then
    system_firmware_${distribution_function_name}
    _system_cpu_vendor_firmware

    kernel_main_${distribution_function_name}
  else
    kernel_zfs_support_${distribution_function_name}
  fi

  _system_cron
  _system_syslog
  _system_indexing

  system_post_${distribution_function_name}
}

_system_patches() {
  _patches_patches lxd incus
}

_system_cpu_vendor_firmware() {
  cpu_vendor=$(lscpu | grep '^Vendor ID:' | awk {'print$3'})
  case $cpu_vendor in
  *Intel*)
    cpu_vendor=Intel
    system_cpu_vendor_firmware_intel_${distribution_function_name}
    ;;
  *AMD*)
    cpu_vendor=AMD
    system_cpu_vendor_firmware_amd_${distribution_function_name}
    ;;
  *)
    exit_with_error "unsupported CPU $cpu_vendor"
    ;;
  esac
}

_system_cron() {
  system_cron_${distribution_function_name}

  [ -z "$cron_packages" ] && return

  _package_install_new_only $cron_packages
  systemctl enable $os_installer_cron
}

_system_syslog() {
  system_syslog_${distribution_function_name}

  [ -z "$syslog_packages" ] && return

  _package_install_new_only $syslog_packages
  systemctl enable $syslog_service_name
}

_system_indexing() {
  system_indexing_${distribution_function_name}
  _package_install_new_only $indexing_packages
}
