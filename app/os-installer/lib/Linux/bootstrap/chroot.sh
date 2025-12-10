lib net/download.sh

_init_chroot() {
	_setup_system_architecture
	_stage3_fetch || {
		[ -n "$stage3_retry" ] && _ERROR "Stage3 failed: already retried"

		_WARN "File failed verification, discarding: $_DOWNLOADED_FILE"
		rm -f $STAGE3_VERSION_FILE $STAGE3_FILE $STAGE3_SIGNATURE_FILE

		stage3_retry=1 _stage3
	}

	_stage3_extract $STAGE3_FILE
}

_stage3_fetch() {
	LATEST_STAGE3_NAME=$(_stage3_latest_version)
	_require "$LATEST_STAGE3_NAME" LATEST_STAGE3_NAME

	_download https://distfiles.gentoo.org/releases/$GENTOO_CPU_ARCHITECTURE/autobuilds/current-stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE/stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE-$LATEST_STAGE3_NAME.tar.xz
	STAGE3_FILE=$_DOWNLOADED_FILE

	_download https://distfiles.gentoo.org/releases/$GENTOO_CPU_ARCHITECTURE/autobuilds/current-stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE/stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE-$LATEST_STAGE3_NAME.tar.xz.asc
	STAGE3_SIGNATURE_FILE=$_DOWNLOADED_FILE

	_gpg_verify $STAGE3_SIGNATURE_FILE
}

_stage3_latest_version() {
	_NO_CACHE=1 _download https://distfiles.gentoo.org/releases/$GENTOO_CPU_ARCHITECTURE/autobuilds/current-stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE/latest-stage3-$GENTOO_CPU_ARCHITECTURE-$GENTOO_STAGE3_TYPE.txt
	STAGE3_VERSION_FILE=$_DOWNLOADED_FILE

	_gpg_verify $STAGE3_VERSION_FILE

	grep "$GENTOO_STAGE3_TYPE" $STAGE3_VERSION_FILE | sed -e 's/\.tar\.xz.*$//' -e 's/^.*\-//'
}

_stage3_extract() {
	tar ${OS_INSTALLER_VERBOSE_TAR}xpf $1 --xattrs-include='*.*' --numeric-owner -C $_CONF_OS_INSTALLER_MOUNTPOINT
}

_prepare_chroot() {
	[ -e /etc/portage/make.conf ] && {
		grep -m1 '^GENTOO_MIRRORS=.*' /etc/portage/make.conf >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	}


	_portage_write_package_license
	_portage_system_use_flags

	_hardware

	printf '# portage - quiet fetch\n' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	printf "FETCHCOMMAND = 'wget -c -v -t 1 --passive-ftp --no-check-certificate --timeout=60 -O \"%s/%s\" \"%s\"'\n" '\${DISTDIR}' '\${FILE}' '\${URI}' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf

	printf 'L10N="%s"\n' "$GENTOO_L10N" >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	printf '# run emerge with lower priority\n' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	printf 'PORTAGE_NICENESS="%s"\n' "$GENTOO_PORTAGE_NICENESS" >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	printf 'PORTAGE_SCHEDULING_POLICY=%s\n' "$GENTOO_PORTAGE_SCHEDULING_POLICY" >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf

	[ -z "$container" ] && {
		_import_gentoo_gpg_keys

		grep -qm1 '^GENTOO_MIRRORS=.*' /etc/portage/make.conf || {
			mirrorselect -s3 -b10 -o >>/etc/portage/make.conf
		}
	}
}

_portage_write_package_license() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.license

	printf '\n\nACCEPT_LICENSE="-* %s"\n' "$GENTOO_SOFTWARE_LICENSE" >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
}

_portage_system_use_flags() {
	printf '# system use flags\n' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	find . -type f -path '*/system/use' -exec $_CONF_GNU_GREP -Pvh '(^$|^#)' {} + |
		tr '\n' ' ' |
		sed -e 's/^/USE="$USE /' -e 's/$/"\n\n/' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
}
