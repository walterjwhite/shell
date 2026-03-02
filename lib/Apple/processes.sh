_processes_is_backgrounded() {
  [ -n "$no_ps" ] && return 1

  case $(ps -o stat= -p $$) in
  *+*)
    return 1
    ;;
  esac

  return 0
}
