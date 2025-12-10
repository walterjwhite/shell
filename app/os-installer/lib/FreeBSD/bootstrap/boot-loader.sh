lib io/file.sh

_boot_loader() {
	[ -z "$(awk '{if ($2=="/boot/efi") printf("%s\n",$1);}' $_CONF_OS_INSTALLER_MOUNTPOINT/etc/fstab)" ] && {
		_WARN "ESP not detected"
		return 1
	}

	case $(uname -m) in
	arm64) ARCHBOOTNAME=aa64 ;;
	amd64) ARCHBOOTNAME=x64 ;;
	riscv) ARCHBOOTNAME=riscv64 ;;
	*) _ERROR "Unsupported arch $(uname -m) for UEFI install" ;;
	esac

	_INFO "Installing loader.efi onto ESP"
	mkdir -p "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/freebsd" "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/boot"
	cp "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/loader.efi" "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/freebsd/loader.efi"

	[ ! -f "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/boot/boot${ARCHBOOTNAME}.efi" ] && {
		_ cp "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/loader.efi" "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/boot/boot${ARCHBOOTNAME}.efi"
	}

	_INFO "Creating UEFI boot entry"

	[ -e "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/freebsd/loader.efi" ] || {
		_WARN "FBSD loader is missing: $_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/freebsd/loader.efi"
		return 1
	}

	efibootmgr --create --activate --label "FreeBSD" --loader "$_CONF_OS_INSTALLER_MOUNTPOINT/boot/efi/efi/freebsd/loader.efi"
}
