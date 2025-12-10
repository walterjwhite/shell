lib net/download.sh

_init_chroot() {
	_dist_freebsd_version

	FREEBSD_BASE_DISTRIBUTION_URL=$(printf '%s/pub/FreeBSD/%s/%s/%s/%s' "$FREEBSD_MIRROR_SITE" $FREEBSD_VERSION_TYPE "$(uname -m)" "$(uname -p)" $FREEBSD_VERSION)

	_CONF_CACHE_PATH=$_CONF_OS_INSTALLER_MOUNTPOINT/var/cache/pkg _download "$FREEBSD_BASE_DISTRIBUTION_URL/MANIFEST" || _ERROR "Unable to download manifest"
	local manifest_file=$_DOWNLOADED_FILE

	local distribution distribution_checksum
	for distribution in $FREEBSD_DISTRIBUTIONS; do
		_CONF_CACHE_PATH=$_CONF_OS_INSTALLER_MOUNTPOINT/var/cache/pkg _download "$FREEBSD_BASE_DISTRIBUTION_URL/$distribution.txz" || _ERROR "Unable to download distribution"
		distribution_checksum=$(sha256 -q $_DOWNLOADED_FILE)

		awk -v checksum=$distribution_checksum -v dist=$distribution.txz -v found=0 '{
      if (dist == $1) {
        found = 1
        if (checksum == $2)
          exit(0)
        else
          exit(2)
      }
    } END {if (!found) exit(1);}' $manifest_file || _ERROR "Checksum failed: $distribution"

		_DETAIL "Extracting $distribution"
		tar -xf "$_DOWNLOADED_FILE" -C $_CONF_OS_INSTALLER_MOUNTPOINT --exclude boot/efi
	done

	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi

	ln -s /tmp/install-v2 $_CONF_OS_INSTALLER_MOUNTPOINT/tmp
}

_dist_freebsd_version() {
	case $FREEBSD_VERSION in
	*-RELEASE)
		FREEBSD_VERSION_TYPE=releases
		;;
	*)
		FREEBSD_VERSION_TYPE=snapshots
		;;
	esac
}

_prepare_chroot() {
	chroot $_CONF_OS_INSTALLER_MOUNTPOINT /usr/bin/newaliases >/dev/null 2>&1
}
