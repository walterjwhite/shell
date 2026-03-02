lib net/download.sh

_init_chroot() {
  _mount_data_cache

  _dist_freebsd_version

  local freebsd_base_distribution_url="$os_installer_mirror_site/pub/FreeBSD/$_os_installer_version_type/$(uname -m)/$(uname -p)/$os_installer_version"

  _download_fetch "$freebsd_base_distribution_url/MANIFEST" || exit_with_error "unable to download manifest"
  local manifest_file=$download_file

  local distribution distribution_checksum
  for distribution in $os_installer_distributions; do
    _download_fetch "$freebsd_base_distribution_url/$distribution.txz" || exit_with_error "unable to download distribution"
    distribution_checksum=$(sha256 -q $download_file)

    awk -v checksum=$distribution_checksum -v dist=$distribution.txz -v found=0 '{
      if (dist == $1) {
        found = 1
        if (checksum == $2)
          exit(0)
        else
          exit(2)
      }
    } END {if (!found) exit(1);}' $manifest_file || exit_with_error "checksum failed: $distribution"

    log_detail "extracting $distribution -> $conf_os_installer_mountpoint"
    tar -xkf "$download_file" -C $conf_os_installer_mountpoint
  done

  mkdir -p $conf_os_installer_mountpoint/boot/efi

}

_dist_freebsd_version() {
  case $os_installer_version in
  *-RELEASE)
    local _os_installer_version_type=releases
    ;;
  *)
    local _os_installer_version_type=snapshots
    ;;
  esac
}

_prepare_chroot() {
  chroot $conf_os_installer_mountpoint /usr/bin/newaliases >/dev/null 2>&1


}
