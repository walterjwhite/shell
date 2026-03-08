lib ./bootstrap/git.sh
lib ./chroot/configure.sh
lib ./chroot/incus-live.sh

cfg .
cfg git


incus_path=incus

patch_incus() {
  [ -n "$_in_container" ] && {
    log_warn "in container, aborting"
    return
  }

  _patch_incus_pre
  _incus_live_pre

  for _INCUS_CONFIGURATION_FILE in $(find /tmp/os -type f -path '*.patch/incus' | sort); do
    log_info "provisioning incus container: $_INCUS_CONFIGURATION_FILE"
    _incus_live "$_INCUS_CONFIGURATION_FILE"
  done

  log_detail "after patch_incus"
}

_patch_incus_pre() {
  patch_incus_prepare_${distribution_function_name}

  grep -qm1 'root:1000000' /etc/subuid || {
    log_detail "configuring users and groups for incus"
    printf 'root:1000000:1000000000\n' | tee -a /etc/subuid /etc/subgid >/dev/null
  }

  _incus_live_start
}

patch_incus_prepare_arch() {
  _package_install_new_only incus
}

patch_incus_prepare_gentoo() {
  _package_install_new_only app-containers/incus
}
