_PATCH_CUPS_PRINTER() {
	local cups_printer_conf
	for cups_printer_conf in $@; do
		_cups_printer_add $cups_printer_conf
	done
}

_cups_printer_add() {
	_cups_printer_exists $1 || {
		_INFO "Adding $1"
		cat $1 >>$_CONF_OS_INSTALLER_CUPS_CONF_DIR/printers.conf
	}
}

_cups_printer_exists() {
	[ ! -e $_CONF_OS_INSTALLER_CUPS_CONF_DIR/printers.conf ] && return 1

	local printer_uuid=$(grep ^UUID $1 | sed -e 's/UUID urn:uuid://')
	if [ $(grep -c $printer_uuid $_CONF_OS_INSTALLER_CUPS_CONF_DIR/printers.conf) -eq 0 ]; then
		return 1
	fi

	_WARN "Printer ($printer_uuid) already exists"
	return 0
}
