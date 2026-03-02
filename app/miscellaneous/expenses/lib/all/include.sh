lib time.sh

_expenses_set_filename() {
  if [ $# -gt 0 ]; then
    if [ -d $1 ]; then
      _expenses_filename $1
    else
      local _expenses_file=$1
    fi

    shift
    return
  fi

  _expenses_filename
  return 1
}

_expenses_filename() {
  local decade=$(_time_decade)
  local name=$(date +%Y)

  local directory=$APP_DATA_PATH
  if [ $# -gt 0 ]; then
    directory=$1
    shift
  fi

  local _expenses_file=$directory/.expenses/$decade/$name.csv
  mkdir -p $(dirname $_expenses_file)
}
