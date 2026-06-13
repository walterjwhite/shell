_mktemp_mktemp() {
  local _suffix=$1
  [ -n "$_suffix" ] && _suffix=".$_suffix"

  mktemp -"${_mktemp_options}"t "${APPLICATION_NAME}.${APPLICATION_CMD}${_suffix}"
}
