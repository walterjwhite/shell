lib open.sh

_show_qr_code_data() {
  exit_defer _tmp_cleanup_temp "$1"
  _open_open "$1"
}

_qr_write() {
  local temp_file=$(_mktemp_mktemp)
  [ -n "$conf_transfer_suffix" ] && {
    mv $temp_file $temp_file.$conf_transfer_suffix
    temp_file=$temp_file.$conf_transfer_suffix
  }

  printf '%s\n' "$secret_value" | qrencode -o $temp_file
  _show_qr_code_data $temp_file
}

_qr_write_from_file() {
  qrencode -r $2 -o $1
  _show_qr_code_data $1
}
