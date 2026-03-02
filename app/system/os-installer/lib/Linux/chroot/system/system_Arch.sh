system_locale_arch() {
  :
}

time_synchronization_arch() {
  local time_sync_packages
  case $os_installer_time_synchronization in
  chronyd)
    time_sync_packages=chrony
    ;;
  ntpd)
    time_sync_packages=ntp
    ;;
  timedatectl)
    [ -n "$os_installer_time_synchronization_enable_ntp" ] && timedatectl set-ntp true

    return
    ;;
  esac

  _package_install_new_only $time_sync_packages
}

system_firmware_arch() {
  _package_install_new_only linux-firmware
}

system_cpu_vendor_firmware_intel_arch() {
  _package_install_new_only intel-ucode
}

system_cpu_vendor_firmware_amd_arch() {
  _package_install_new_only amd-ucode
}

system_cron_arch() {
  local cron_packages
  case $os_installer_cron in
  cronie | fcron)
    cron_packages=$os_installer_cron
    ;;
  bcron | dcron)
    exit_with_error "$os_installer_cron is not presently supported"
    ;;
  systemd)
    log_warn "using systemd cron mechanism"
    return 0
    ;;
  esac
}

system_syslog_arch() {
  :
}

system_indexing_arch() {
  case $os_installer_indexing in
  plocate)
    indexing_packages=plocate
    _updatedb_cmd=/usr/bin/updatedb
    ;;
  *)
    exit_with_error "unknown indexing provider: $os_installer_indexing"
    ;;
  esac
}

system_pre_arch() {
  :
}

system_post_arch() {
  :
}
