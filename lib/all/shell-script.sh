_shell_script_is_shell_script() {
  case $1 in
  *.sh)
    return 0
    ;;
  esac

  head -1 $1 | $GNU_GREP -Pcq 'sh$'
}
