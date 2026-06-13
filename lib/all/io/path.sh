_path_in_path() {
  local _check_path=$1
  validation_require "$_check_path" _path_in_path

  local test_path=$(readlink -f "$_check_path")
  readlink -f "$PWD" | grep -c "^$test_path" >/dev/null 2>&1
}

_path_in_application_data_path() {
  _path_in_path "$APP_DATA_PATH"
}

_path_in_data_path() {
  _path_in_path "$DATA_PATH"
}

_path_remove_empty_directories() {
  local _directory=$1
  find "$_directory" -type d -empty -exec rm -rf {} +
}
