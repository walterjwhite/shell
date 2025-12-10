_SECRETS_GENERATE() {
	case $_CONF_SECRETS_GENERATE_CAPITALIZE in
	1)
		_secrets_pass_options -c
		;;
	0)
		_secrets_pass_options -A
		;;
	esac

	case $_CONF_SECRETS_GENERATE_NUMERALS in
	1)
		_secrets_pass_options -n
		;;
	0)
		_secrets_pass_options -0
		;;
	esac

	case $_CONF_SECRETS_GENERATE_SYMBOLS in
	1)
		_secrets_pass_options -y
		;;
	esac

	case $_CONF_SECRETS_GENERATE_NO_AMBIGUOUS in
	1)
		_secrets_pass_options -B
		;;
	esac

	[ -n "$_OPTN_SECRETS_REMOVE_SYMBOLS" ] && _secrets_pass_options "-r $_OPTN_SECRETS_REMOVE_SYMBOLS"
	pwgen -s $_PASS_OPTIONS $_CONF_SECRETS_PASSWORD_LENGTH 1
}

_secrets_pass_options() {
	_PASS_OPTIONS="$_PASS_OPTIONS $1"
}
