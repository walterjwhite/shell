_load_modules() {
  lsmod | grep -qm1 ^iptable_filter || modprobe iptable_filter
  lsmod | grep -qm1 ^ip6table_filter || modprobe ip6table_filter
  lsmod | grep -qm1 ^br_netfilter || modprobe br_netfilter
}

_import_gentoo_gpg_keys() {
  gpg --import $conf_os_installer_mountpoint/usr/share/openpgp-keys/gentoo-release.asc
}

_gpg_verify() {
  validation_require "$1" "File to verify with GPG"

  local gpg_output=$(gpg --verify "$1" 2>&1)
  local gpg_status=$?
  [ $gpg_status -gt 0 ] && {
    exit_with_error "$gpg_output" $gpg_status
  }

  log_detail "gpg verification completed"
}


_validate_conf() {
  validation_require "$os_installer_init" "os_installer_init"
  _validation_value_in "$os_installer_init" "bliss|dracut|ugrd|walterjwhite"

  validation_require "$os_installer_boot_loader" "os_installer_boot_loader"
  _validation_value_in "$os_installer_boot_loader" "efibootmgr|grub"

  validation_require "$os_installer_cron" "os_installer_cron [cronie|dcron|fcron|bcron|anacron|systemd]"
  _validation_value_in "$os_installer_cron" "cronie|dcron|fcron|bcron|anacron|systemd"

  validation_require "$os_installer_syslog" "os_installer_syslog [sysklogd|syslog-ng|rsyslog|metalog]"
  _validation_value_in "$os_installer_syslog" "sysklogd|syslog-ng|rsyslog|metalog"

  validation_require "$os_installer_kernel" "os_installer_kernel [gentoo-kernel]"
  _validation_value_in "$os_installer_kernel" "gentoo-kernel"
}
