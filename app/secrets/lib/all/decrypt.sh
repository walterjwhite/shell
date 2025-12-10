_SECRETS_DECRYPT() {
	_ENCRYPTION_OUTPUT_FILE=$(printf '%s' "$_ENCRYPTION_SOURCE_FILE" | sed -e 's/\.asc$//' -e 's/\.gpg$//')
	[ -e "$_ENCRYPTION_OUTPUT_FILE" ] && _ERROR "$_ENCRYPTION_OUTPUT_FILE exists"

	_INFO "Writing decrypted file to: $_ENCRYPTION_OUTPUT_FILE"
	gpg --decrypt $_ENCRYPTION_SOURCE_FILE >$_ENCRYPTION_OUTPUT_FILE
}
