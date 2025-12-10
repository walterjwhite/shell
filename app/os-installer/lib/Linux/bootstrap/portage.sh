_hardware() {
	_write_cpu_flags

	[ -z "$GENTOO_VIDEO_CARDS" ] && _get_video_cards
	_write_video_cards

	_makeopts
}

_makeopts() {
	local system_memory=$(free -g | awk '/^Mem:/{print $2}')

	local allowed_jobs=$(($system_memory / 2))
	local load_average=$(($allowed_jobs + 1))

	printf '# @see: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#MAKEOPTS\n' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
	printf 'MAKEOPTS="-j%s -l%s"\n' $allowed_jobs $load_average >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf
}

_setup_system_architecture() {
	local system_architecture=$(lscpu | grep Architecture | awk {'print$2'})
	case $system_architecture in
	x86_64)
		GENTOO_CPU_ARCHITECTURE=amd64
		;;
	*)
		_ERROR "Unsupported architecture: $system_architecture"
		;;
	esac
}

_get_video_cards() {
	oIFS="$IFS"
	IFS=$'\n'

	local lspci_line
	local video_api="vulkan"

	for lspci_line in $(lspci | $_CONF_GNU_GREP -Pi '(VGA compatible controller|Display controller)'); do
		case $lspci_line in
		*AMD/ATI*)
			GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS radeon radeonsi"
			mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.use
			printf 'x11-libs/libdrm video_cards_amdgpu\n' >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.use/amdgpu
			;;
		*Intel\ Corporation*)
			GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS intel"
			;;
		*Intel\ Corporation*)
			GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS intel"
			;;
		*NVIDIA\ Corporation*)
			case $lspci_line in
			*K3100M*)
				GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS nouveau"
				video_api="$video_api vaapi"
				;;
			*)
				if [ -n "$GENTOO_PROPRIETARY_NVIDIA" ]; then
					GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS nvidia"
				else
					GENTOO_VIDEO_CARDS="$GENTOO_VIDEO_CARDS nouveau"
					video_api="$video_api vaapi"
				fi

				;;
			esac

			video_api="$video_api cuda vdpau nvenc"
			;;
		*)
			printf 'Other: %s\n' "$lspci_line"
			;;
		esac
	done

	printf '# video cards\nUSE="$USE %s"\n\n' "$video_api" >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/make.conf

	IFS="$oIFS"
}

_write_cpu_flags() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.use
	printf '*/* %s\n' "$(cpuid2cpuflags)" >$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.use/00cpu-flags
}

_write_video_cards() {
	printf '*/* VIDEO_CARDS: -* %s\n' "$GENTOO_VIDEO_CARDS" >$_CONF_OS_INSTALLER_MOUNTPOINT/etc/portage/package.use/00video
}
