lib qr.sh

_SECRETS_GET() {
	. $_CONF_APPLICATION_LIBRARY_PATH/provider/$_CONF_SECRETS_PROVIDER/get.sh

	if [ $# -gt 0 ]; then
		case $1 in
		-out=*)
			_SECRETS_OUTPUT_FUNCTION=${1#*=}
			shift
			;;
		esac
	fi

	_secrets_get_key "$@"
	_secrets_get_output_function

	if [ "$_SECRETS_OUTPUT_FUNCTION" != "wifi" ]; then
		_SECRETS_OUTPUT_FUNCTION_NAME=$(printf '%s' $_SECRETS_OUTPUT_FUNCTION | tr '[[:lower:]]' '[[:upper:]]')
		_SECRETS_GET_$_SECRETS_OUTPUT_FUNCTION_NAME "$@"
	else
		_SECRETS_GET_WIFI "$@"
	fi
}

_secrets_get_key() {
	[ $# -eq 0 ] && _ERROR "key name or search pattern is required"

	_SECRETS_GET_FIND "$@"
}

_secrets_get_output_function() {
	case $_SECRETS_OUTPUT_FUNCTION in
	clipboard | qrcode | wifi) ;;
	stdout)
		_secrets_get_stdout_formatter
		;;
	*)
		_ERROR "Invalid output function: $_SECRETS_OUTPUT_FUNCTION"
		;;
	esac
}

_secrets_get_stdout_formatter() {
	_SECRETS_OUTPUT_FUNCTION=stdout

	[ -n "$_FORCE_INTERACTIVE" ] && return 1

	local type=$(printf '%s' "$_SECRET_KEY" | sed -e 's/^.*\///')

	case $type in
	*pin*)
		_STDOUT_FORMAT=pin
		;;
	*number* | *account* | *member*)
		_STDOUT_FORMAT=account
		;;
	*phone*)
		_STDOUT_FORMAT=phone
		;;
	esac

	[ -n "$_STDOUT_FORMAT" ] && _SECRETS_OUTPUT_FUNCTION=stdout_format
}

_SECRETS_GET_STDOUT_PIN() {
	sed -r -e 's/^.{3}/& /'
}

_SECRETS_GET_STDOUT_PHONE() {
	sed -r -e 's/^.{3}/& /' -e 's/^.{7}/& /'
}

_SECRETS_GET_STDOUT_ACCOUNT() {
	sed -r -e 's/^.{4}/& /' -e 's/^.{9}/& /' -e 's/^.{14}/& /' -e 's/^.{19}/& /'
}

_SECRETS_GET_STDOUT_FORMAT() {
	_SECRETS_GET_STDOUT | _SECRETS_GET_STDOUT_$_STDOUT_FORMAT
}

_SECRETS_GET_QRCODE() {
	[ -z "$secret_value" ] && secret_value=$(_SECRETS_GET_STDOUT)
	_qr_write
}

_SECRETS_GET_WIFI() {
	local ssid=$(_SECRET_KEY=$_SECRET_KEY/ssid _SECRETS_GET_STDOUT 2>/dev/null)
	local encryption_type=$(_SECRET_KEY=$_SECRET_KEY/encryption-type _SECRETS_GET_STDOUT 2>/dev/null)
	local key=$(_SECRET_KEY=$_SECRET_KEY/key _SECRETS_GET_STDOUT 2>/dev/null)

	_require "$ssid" ssid
	_require "$encryption_type" encryption_type
	_require "$key" key

	local is_hidden=$(_SECRET_KEY=$_SECRET_KEY/is-hidden _SECRETS_GET_STDOUT 2>/dev/null)
	secret_value="WIFI:S:$ssid;T:$encryption_type;P:$key;H:$is_hidden;;" _SECRETS_GET_QRCODE
}
