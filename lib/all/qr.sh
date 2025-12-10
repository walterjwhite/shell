lib open.sh

_show_qr_code_data() {
	_defer _cleanup_temp "$1"
	_open "$1"
}

_qr_write() {
	local temp_file=$(_mktemp)
	[ -n "$_CONF_TRANSFER_SUFFIX" ] && {
		mv $temp_file $temp_file.$_CONF_TRANSFER_SUFFIX
		temp_file=$temp_file.$_CONF_TRANSFER_SUFFIX
	}

	printf '%s\n' "$secret_value" | qrencode -o $temp_file
	_show_qr_code_data $temp_file
}

_qr_write_from_file() {
	qrencode -r $2 -o $1
	_show_qr_code_data $1
}
