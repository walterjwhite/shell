init_chroot_gentoo() {
  _setup_system_architecture
  _stage3_fetch || {
    [ -n "$stage3_retry" ] && exit_with_error "stage3 failed: already retried"

    log_warn "file failed verification, discarding: $download_file"
    rm -f $_stage3_version_file $_stage3_file $_stage3_signature_file

    stage3_retry=1 _stage3
  }

  _stage3_extract $_stage3_file
}

_stage3_fetch() {
  _stage3_latest_version
  validation_require "$_latest_stage3_name" _latest_stage3_name

  log_detail "using $_latest_stage3_name"

  _download_fetch "https://distfiles.gentoo.org/releases/$_os_installer_cpu_architecture/autobuilds/current-stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type/stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type-$_latest_stage3_name.tar.xz"
  _stage3_file=$download_file

  _download_fetch "https://distfiles.gentoo.org/releases/$_os_installer_cpu_architecture/autobuilds/current-stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type/stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type-$_latest_stage3_name.tar.xz.asc"
  _stage3_signature_file=$download_file

  _gpg_verify $_stage3_signature_file
}

_stage3_latest_version() {
  _no_cache=1 _download_fetch https://distfiles.gentoo.org/releases/$_os_installer_cpu_architecture/autobuilds/current-stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type/latest-stage3-$_os_installer_cpu_architecture-$os_installer_stage3_type.txt
  _stage3_version_file=$download_file

  _gpg_verify $_stage3_version_file

  _latest_stage3_name=$(grep -h "$os_installer_stage3_type" $_stage3_version_file | awk {'print$1'} | sed -e 's/\.tar\.xz.*$//' -e 's/^.*\-//')
}

_stage3_extract() {
  tar ${verbose_tar}xpf $1 --xattrs-include='*.*' --numeric-owner -C $conf_os_installer_mountpoint
}

prepare_chroot_gentoo() {


  _portage_write_package_license
  _portage_system_use_flags

  _portage_hardware

  (
    printf '# portage - quiet fetch\n'
    printf "FETCHCOMMAND = 'wget -c -v -t 1 --passive-ftp --no-check-certificate --timeout=60 -O \"%s/%s\" \"%s\"'\n" '\${DISTDIR}' '\${FILE}' '\${URI}'

    printf 'L10N="%s"\n' "$os_installer_l10n"
    printf '# run emerge with lower priority\n'
    printf 'PORTAGE_NICENESS="%s"\n' "$os_installer_portage_niceness"
    printf 'PORTAGE_SCHEDULING_POLICY=%s\n' "$os_installer_portage_scheduling_policy"
  ) >>$conf_os_installer_mountpoint/etc/portage/make.conf

  [ -z "$_in_container" ] && {
    _import_gentoo_gpg_keys
    _setup_mirrors
  }
}

_setup_mirrors() {
  grep -qm1 '^GENTOO_MIRRORS=.*' /etc/portage/make.conf || {
    log_warn "installing mirrorselect to determine mirror"

    _package_install_new_only app-portage/mirrorselect
    mirrorselect -S -s3 -b10
  }
}

_portage_write_package_license() {
  mkdir -p $conf_os_installer_mountpoint/etc/portage/package.license

  printf '\n\nACCEPT_LICENSE="-* %s"\n' "$os_installer_software_license" >>$conf_os_installer_mountpoint/etc/portage/make.conf
}

_portage_system_use_flags() {
  printf '# system use flags\n' >>$conf_os_installer_mountpoint/etc/portage/make.conf
  find . -type f -path '*/system/use' -exec $GNU_GREP -Pvh '(^$|^#)' {} + |
    tr '\n' ' ' |
    sed -e 's/^/USE="$USE /' -e 's/$/"\n\n/' >>$conf_os_installer_mountpoint/etc/portage/make.conf
}
