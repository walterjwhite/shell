_system() {
	_locale
	_timezone

	[ -z "$container" ] && _time_synchronization

	_module_set_log newuse && _EXEC_ATTEMPTS=3 _ _PACKAGE_UPDATE

	_PRESERVE_LOG=1 _set_logfile $_LOGFILE

	if [ -z "$container" ]; then
		_firmware

		_kernel

		_initramfs
	else
		_kernel_container
	fi

	_cron
	_syslog
	_indexing

	_patches use
	_module_set_log newuse && _EXEC_ATTEMPTS=3 _ _PACKAGE_UPDATE
}

_system_patches() {
	[ -z "$container" ] && _patches lxd incus
}

_locale() {
	printf '%s\n' "$GENTOO_SYSTEM_LOCALE_GEN" | tr '|' '\n' >/etc/locale.gen
	locale-gen

	eselect locale set $GENTOO_SYSTEM_LOCALE_ESELECT
	. /etc/profile
}

_timezone() {
	ln -sf /usr/share/zoneinfo/$GENTOO_SYSTEM_TIMEZONE /etc/localtime
}

_time_synchronization() {
	local time_sync_packages
	case $GENTOO_TIME_SYNCHRONIZATION in
	chronyd)
		time_sync_packages=net-misc/chrony
		;;
	ntpd)
		time_sync_packages=snet-misc/ntp
		mkdir -p /etc/portage/package.use
		printf 'net-misc/ntp openntpd\n' >>/etc/portage/package.use/ntp
		;;
	timedatectl)
		[ -n "$GENTOO_TIME_SYNCHRONIZATION_ENABLE_NTP" ] && timedatectl set-ntp true

		;;
	esac

	_PACKAGE_INSTALL $time_sync_packages
	$_CONF_OS_INSTALLER_INIT_CMD $GENTOO_TIME_SYNCHRONIZATION
}

_firmware() {
	mkdir -p /etc/portage/package.license
	printf 'sys-kernel/linux-firmware linux-fw-redistributable\n' >>/etc/portage/package.license/firmware

	_PACKAGE_INSTALL sys-kernel/linux-firmware

	_get_cpu_vendor

	case $GENTOO_CPU_VENDOR in
	Intel)
		printf 'sys-firmware/intel-microcode intel-ucode\n' >>/etc/portage/package.license/firmware
		_PACKAGE_INSTALL sys-firmware/intel-microcode
		;;
	AMD)
		;;
	*)
		_WARN "Unknown CPU: $GENTOO_CPU_VENDOR"
		;;
	esac
}

_get_cpu_vendor() {
	local cpu_vendor=$(lscpu | grep '^Vendor ID:' | awk {'print$3'})
	case $cpu_vendor in
	*Intel*)
		GENTOO_CPU_VENDOR=Intel
		;;
	*AMD*)
		GENTOO_CPU_VENDOR=AMD
		;;
	*)
		_ERROR "Unsupported CPU $cpu_vendor"
		;;
	esac
}

_cron() {
	local cron_packages
	case $GENTOO_CRON in
	cronie)
		cron_packages=sys-process/cronie
		;;
	bcron)
		cron_packages=sys-process/bcron
		;;
	dcron)
		cron_packages=sys-process/dcron
		;;
	fcron)
		cron_packages=sys-process/fcron
		;;
	esac

	_PACKAGE_INSTALL $cron_packages
	_SERVICE_$_CONF_OS_INSTALLER_INIT $GENTOO_CRON
}

_syslog() {
	local service_name="$GENTOO_SYSLOG"
	case $GENTOO_SYSLOG in
	sysklogd)
		[ -n "$GENTOO_SYSLOG_USE" ] && printf 'app-admin/sysklogd %s\n' "$GENTOO_SYSLOG_USE" >>/etc/portage/package.use/sysklogd
		syslog_packages=app-admin/sysklogd
		service_name=syslogd.service
		;;
	*)
		_ERROR "Unknown syslog provider: $GENTOO_SYSLOG"
		;;
	esac

	_PACKAGE_INSTALL $syslog_packages
	_SERVICE_$_CONF_OS_INSTALLER_INIT $service_name boot
}

_indexing() {
	case $GENTOO_INDEXING in
	plocate)
		indexing_packages=sys-apps/plocate
		;;
	*)
		_ERROR "Unknown indexing provider: $GENTOO_INDEXING"
		;;
	esac

	_PACKAGE_INSTALL $indexing_packages
}

_SERVICE_OPENRC() {
	rc-update add "$@"
}

_SERVICE_SYSTEMD() {
	systemctl enable $1
}
