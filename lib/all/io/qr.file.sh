_qr_file_send_file() {
  local _data_filename=$1
  file_require "$_data_filename"
  qr_file_data_filename=$(readlink -f "$_data_filename")

  local _file_size=$(wc -c <"$qr_file_data_filename" | awk {'print$1'})
  if [ "$_file_size" -gt "$conf_transfer_max_data_size" ]; then
    exit_with_error "$qr_file_data_filename is too large to send [$_file_size] > $conf_transfer_max_data_size"
  fi

  secret_value="filename=$qr_file_data_filename" _qr_write

  _qr_file_send_file_data
}

_qr_file_send_file_data() {
  qr_file_temp_dir=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer _tmp_cleanup_temp "$qr_file_temp_dir"

  local _old_pwd=$PWD
  cd "$qr_file_temp_dir"

  $conf_transfer_split_function
  for file_segment in $(ls); do
    _qr_write_from_file "$file_segment.png" "$file_segment"
    _stdin_continue_if "Press enter when complete:" "Y/n"
  done

  cd "$_old_pwd"
}
