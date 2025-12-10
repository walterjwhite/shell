for _ARG in "$@"; do
	case $_ARG in
	-request=*)
		_REQUEST_KEY=${_ARG#*=}
		_REQUEST=$_REQUEST_KEY/request

		_secrets_init

		_ARGS="$_ARGS --print=HhBb"
		;;
	-q | --quiet)
		_ARGS="$_ARGS --quiet"
		;;
	--no-log-env)
		_NO_LOG_ENV=1
		;;
	-s=*)
		_SECRET=${_ARG#*=}
		_KEY_NAME=${_SECRET%%=*}
		_SECRET_KEY=${_SECRET#*=}

		_INFO "Handling secret: $_SECRET | $_KEY_NAME | $_SECRET_KEY"
		export $_KEY_NAME=$(secrets get -o=s $_SECRET_KEY)

		unset _SECRET _KEY_NAME _SECRET_KEY
		;;
	--timeout=*)
		_TIMEOUT=${_ARG#*=}
		;;
	-auth=* | -a=*)
		_AUTH=${_ARG#*=}
		;;
	--auth-type=* | -A=*)
		_AUTH_TYPE=${_ARG#*=}
		;;
	*)
		_ARGS="$_ARGS $_ARG"
		;;
	esac
done

_ARGS="$_ARGS --timeout $_TIMEOUT"
