_system() {
  _freebsd_hostname
  _indexing

  [ -n "$_in_container" ] && return

  _freebsd_update

  _package_install_new_only cpu-microcode || {
    exit_with_error "error installing cpu-microcode"
    return 1
  }

  _enable_cpu_microcode_patches
  _patch_microcode
}

_freebsd_hostname() {
  sysrc hostname="$conf_os_hostname"
}

_system_patches() {
  _patches_patches jail periodic rc boot_loader
}

_enable_cpu_microcode_patches() {
  local cpu_vendor=intel
  if [ $(sysctl -a | egrep -i 'hw.model' | grep -ic amd) -gt 0 ]; then
    cpu_vendor=amd
  fi

  printf 'microcode_update_enable="YES"\n' >>/etc/rc.conf

  printf '# freebsd-installer - microcode updates\n' >>/boot/loader.conf

  printf 'cpu_microcode_load="YES"\n' >>/boot/loader.conf
  printf 'cpu_microcode_name="/boot/firmware/%s-ucode.bin"\n' "$cpu_vendor" >>/boot/loader.conf

  log_info "installed support for patching CPU microcode ($cpu_vendor)"
}

_patch_microcode() {
  log_warn "patching CPU microcode"
  service microcode_update start
}

_indexing() {
  case $os_installer_indexing in
  mlocate)
    indexing_packages=mlocate
    _updatedb_cmd=/usr/libexec/locate.updatedb
    ;;
  plocate)
    indexing_packages=plocate
    _updatedb_cmd=/usr/local/sbin/updatedb
    ;;
  *)
    exit_with_error "unknown indexing provider: $os_installer_indexing"
    ;;
  esac

  _package_install_new_only $indexing_packages
}
