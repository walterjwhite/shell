_send_file() {
	_require_file "$_DATA_FILENAME"
	_DATA_FILENAME=$(readlink -f $_DATA_FILENAME)

	local file_size=$(wc -c <$_DATA_FILENAME | awk {'print$1'})
	if [ $file_size -gt $_CONF_TRANSFER_MAX_DATA_SIZE ]; then
		_ERROR "$_DATA_FILENAME is too large to send [$file_size] > $_CONF_TRANSFER_MAX_DATA_SIZE"
	fi

	secret_value="filename=$_DATA_FILENAME" _qr_write

	_send_file_data
}

_send_file_data() {
	temp_dir=$(_MKTEMP_OPTIONS=d _mktemp)
	_defer _cleanup_temp "$temp_dir"

	local opwd=$PWD
	cd $temp_dir

	$_CONF_TRANSFER_SPLIT_FUNCTION
	for _FILE_SEGMENT in $(ls); do
		_qr_write_from_file $_FILE_SEGMENT.png $_FILE_SEGMENT
		_continue_if "Press enter when complete:" "Y/n"
	done

	cd $opwd
}
