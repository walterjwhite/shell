_include_optional() {
  inc_err=0
  inc_dir="$HOME/.config/walterjwhite/shell"

  for inc_file in "$@"; do
    case "$inc_file" in
    */*) ;;
    *)
      inc_file="$inc_dir/$inc_file"
      ;;
    esac

    if [ -f "$inc_file" ] && . "$inc_file"; then
      :
    else
      inc_err=$(($inc_err + 1))
    fi
  done

  unset inc_file inc_dir
  [ "$inc_err" -eq 0 ]
}
