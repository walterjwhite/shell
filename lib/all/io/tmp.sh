_tmp_defer_cleanup_tmp() {
  local _defer_path=$1
  [ -z "$tmp_cleanup_defers" ] && exit_defer _tmp_cleanup_temp

  tmp_cleanup_defers="${tmp_cleanup_defers:+$tmp_cleanup_defers }$_defer_path"
}

_tmp_cleanup_temp() {
  [ -z "$tmp_cleanup_defers" ] && return 1

  rm -rf $tmp_cleanup_defers
  unset tmp_cleanup_defers
}
