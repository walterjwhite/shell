system_locale_gentoo() {
  printf '%s\n' "$os_installer_system_locale_gen" | tr '|' '\n' >/etc/locale.gen
  locale-gen

  eselect locale set $os_installer_system_locale_eselect
  . /etc/profile
}

time_synchronization_gentoo() {
  local time_sync_packages
  case $os_installer_time_synchronization in
  chronyd)
    time_sync_packages=net-misc/chrony
    ;;
  ntpd)
    time_sync_packages=net-misc/ntp
    mkdir -p /etc/portage/package.use
    printf 'net-misc/ntp openntpd\n' >>/etc/portage/package.use/ntp
    ;;
  timedatectl)
    [ -n "$os_installer_time_synchronization_enable_ntp" ] && timedatectl set-ntp true

    return
    ;;
  esac

  _package_install_new_only $time_sync_packages
}

system_firmware_gentoo() {
  mkdir -p /etc/portage/package.license
  printf 'sys-kernel/linux-firmware linux-fw-redistributable\n' >>/etc/portage/package.license/firmware
  _package_install_new_only sys-kernel/linux-firmware
}

system_cpu_vendor_firmware_intel_gentoo() {
  printf 'sys-firmware/intel-microcode intel-ucode\n' >>/etc/portage/package.license/firmware
  _package_install_new_only sys-firmware/intel-microcode
}

system_cpu_vendor_firmware_amd_gentoo() {
  :
}

system_cron_gentoo() {
  local cron_packages
  case $os_installer_cron in
  cronie | bcron | dcron | fcron)
    cron_packages=sys-process/$os_installer_cron
    ;;
  systemd)
    log_warn "using systemd cron mechanism"
    return 0
    ;;
  esac

  _package_install_new_only $cron_packages
  systemctl enable $os_installer_cron
}

system_syslog_gentoo() {
  local service_name="$os_installer_syslog"
  case $os_installer_syslog in
  sysklogd)
    [ -n "$os_installer_syslog_use" ] && printf 'app-admin/sysklogd %s\n' "$os_installer_syslog_use" >>/etc/portage/package.use/sysklogd
    syslog_packages=app-admin/sysklogd
    syslog_service_name=syslogd.service
    ;;
  *)
    exit_with_error "unknown syslog provider: $os_installer_syslog"
    ;;
  esac
}

system_indexing_gentoo() {
  case $os_installer_indexing in
  plocate)
    indexing_packages=sys-apps/plocate
    _updatedb_cmd=/usr/bin/updatedb
    ;;
  *)
    exit_with_error "unknown indexing provider: $os_installer_indexing"
    ;;
  esac
}

system_pre_gentoo() {
  local original_log_file=$log_logfile
  module=newuse _module_set_log

  _exec_attempts=3 exec_wrap package_update

  log_detail "packages updated"

  log_set_logfile $original_log_file
  unset original_log_file
}

system_post_gentoo() {
  _patches_patches use

  module=newuse _module_set_log
  _exec_attempts=3 exec_wrap package_update
}
