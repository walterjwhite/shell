_SECRETS_ENCRYPT() {
	for _ARG in "$@"; do
		case $_ARG in
		-r=*)
			shift
			_ENCRYPTION_RECIPIENTS="$_ENCRYPTION_RECIPIENTS -r ${_ARG#*=}"
			;;
		-t)
			shift
			_ENCRYPTION_ARGS="$_ENCRYPTION_ARGS -sign --armor"
			;;
		esac
	done

	[ -z "$_ENCRYPTION_RECIPIENTS" ] && _ENCRYPTION_RECIPIENTS="-r $(whoami)"

	gpg --encrypt $_ENCRYPTION_ARGS $_ENCRYPTION_RECIPIENTS $_ENCRYPTION_SOURCE_FILE
}
