for _ARG in "$@"; do
  case $_ARG in
  -request=*)
    local _REQUEST_KEY=${_ARG#*=}
    readonly REQUEST=$_REQUEST_KEY/request

    _secrets_init

    readonly ARGS="$_ARGS --print=HhBb"
    ;;
  -q | --quiet)
    readonly ARGS="$_ARGS --quiet"
    ;;
  --no-log-env)
    readonly NO_LOG_ENV=1
    ;;
  -s=*)
    local _SECRET=${_ARG#*=}
    local _KEY_NAME=${_SECRET%%=*}
    local _SECRET_KEY=${_SECRET#*=}

    log_info "handling secret: $_SECRET | $_KEY_NAME | $_SECRET_KEY"
    export $_KEY_NAME=$(secrets get -o=s $_SECRET_KEY)

    unset _SECRET _KEY_NAME _SECRET_KEY
    ;;
  --timeout=*)
    local _TIMEOUT=${_ARG#*=}
    ;;
  -auth=* | -a=*)
    local _AUTH=${_ARG#*=}
    ;;
  --auth-type=* | -A=*)
    local _AUTH_TYPE=${_ARG#*=}
    ;;
  *)
    readonly ARGS="$_ARGS $_ARG"
    ;;
  esac
done

readonly ARGS="$_ARGS --timeout $_TIMEOUT"
