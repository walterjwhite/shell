_portage_hardware() {
  _write_cpu_flags

  [ -z "$_os_installer_video_cards" ] && _get_video_cards
  _write_video_cards

  _portage_makeopts
}

_portage_makeopts() {
  local system_memory=$(free -g | awk '/^Mem:/{print $2}')

  local allowed_jobs=$(($system_memory / 2))
  local load_average=$(($allowed_jobs + 1))

  printf '# @see: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#MAKEOPTS\n' >>$conf_os_installer_mountpoint/etc/portage/make.conf
  printf 'MAKEOPTS="-j%s -l%s"\n' $allowed_jobs $load_average >>$conf_os_installer_mountpoint/etc/portage/make.conf
}

_setup_system_architecture() {
  local system_architecture=$(lscpu | grep Architecture | awk {'print$2'})
  case $system_architecture in
  x86_64)
    _os_installer_cpu_architecture=amd64
    ;;
  *)
    exit_with_error "unsupported architecture: $system_architecture"
    ;;
  esac
}

_get_video_cards() {
  oifs="$ifs"
  ifs=$'\n'

  local lspci_line
  local video_api="vulkan"

  for lspci_line in $(lspci | $GNU_GREP -Pi '(VGA compatible controller|Display controller)'); do
    case $lspci_line in
    *AMD/ATI*)
      _os_installer_video_cards="$_os_installer_video_cards radeon radeonsi"
      mkdir -p $conf_os_installer_mountpoint/etc/portage/package.use
      printf 'x11-libs/libdrm video_cards_amdgpu\n' >>$conf_os_installer_mountpoint/etc/portage/package.use/amdgpu
      ;;
    *Intel\ Corporation*)
      local _os_installer_video_cards="$_os_installer_video_cards intel"
      ;;
    *Intel\ Corporation*)
      local _os_installer_video_cards="$_os_installer_video_cards intel"
      ;;
    *NVIDIA\ Corporation*)
      case $lspci_line in
      *K3100M*)
        local _os_installer_video_cards="$_os_installer_video_cards nouveau"
        video_api="$video_api vaapi"
        ;;
      *)
        if [ -n "$os_installer_proprietary_nvidia" ]; then
          local _os_installer_video_cards="$_os_installer_video_cards nvidia"
        else
          local _os_installer_video_cards="$_os_installer_video_cards nouveau"
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

  printf '# video cards\nUSE="$USE %s"\n\n' "$video_api" >>$conf_os_installer_mountpoint/etc/portage/make.conf

  ifs="$oifs"
}

_write_cpu_flags() {
  mkdir -p $conf_os_installer_mountpoint/etc/portage/package.use
  printf '*/* %s\n' "$(cpuid2cpuflags)" >$conf_os_installer_mountpoint/etc/portage/package.use/00cpu-flags

  printf 'CFLAGS="${CFLAGS} %s"\n' "$(resolve-march-native -a)" >>$conf_os_installer_mountpoint/etc/portage/make.conf
}

_write_video_cards() {
  printf '*/* VIDEO_CARDS: -* %s\n' "$_os_installer_video_cards" >$conf_os_installer_mountpoint/etc/portage/package.use/00video
}
