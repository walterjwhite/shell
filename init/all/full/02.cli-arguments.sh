for _ARG in "$@"; do
  case $_ARG in
  -h | --help)
    _help_print_and_exit
    ;;
  -w=*)
    wait_waiter_pid="${1#*=}"
    shift
    ;;
  -w)
    readonly WAIT_WAITEE=1
    shift
    ;;
  -conf-* | -[a-z0-9][a-z0-9][a-z0-9]*)
    _configuration_name=${_ARG#*-}
    _configuration_name=${_configuration_name%%=*}

    printf '%s' "$_configuration_name" | grep -cqm1 '_$' && {
      _configuration_name=${_configuration_name%%_*}

      printf '%s' "$_configuration_name" | grep -cqm1 '^conf' && {
        _configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/-/-$APPLICATION_NAME-/" -e 's/--/-/')
      } || {
        _configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/^/$APPLICATION_NAME-/" -e 's/--/-/')
      }
    }

    _configuration_name=$(printf '%s' $_configuration_name | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    case "$_ARG" in
    *-*)
      _configuration_value=${_ARG#*=}
      ;;
    *)
      _configuration_value=1
      ;;
    esac

    eval "${_configuration_name}=\"$_configuration_value\""
    unset _configuration_name _configuration_value
    shift
    ;;
  --last-arg)
    shift
    break
    ;;

  *)
    break
    ;;
  esac
done

log_enable_debug_mode
