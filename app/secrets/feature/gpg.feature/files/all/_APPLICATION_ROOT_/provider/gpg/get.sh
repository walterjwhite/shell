lib feature/gpg.feature/gpg.sh

_SECRETS_GPG_GET() {
	[ -z "$_SECRET_KEY_PATH" ] && {
		case $_SECRET_KEY in
		*.gpg)
			_SECRET_KEY_PATH=$_SECRET_KEY
			;;
		*)
			_SECRET_KEY_PATH=$_SECRET_KEY.gpg
			;;
		esac
	}

	gpg -d $_SECRET_KEY_PATH 2>/dev/null
}

_SECRETS_GET_STDOUT() {
	_SECRETS_GPG_GET
}

_SECRETS_GET_FIND() {
	[ $# -eq 0 ] && return 1

	local matched=$(. $_CONF_APPLICATION_LIBRARY_PATH/provider/$_CONF_SECRETS_PROVIDER/find.sh)
	local matches=$(printf '%s\n' $matched | wc -l)

	[ -z "$matched" ] && _ERROR "No secrets found matching: $*"
	[ $matches -ne 1 ] && _ERROR "Expecting exactly 1 secret to match, instead found: $matches"

	_SECRET_KEY_PATH=$matched
}

_SECRETS_GET_CLIPBOARD() {
	_SECRETS_GPG_GET | _clipboard_put
}
