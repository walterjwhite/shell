_vault_auth() {
	local auth_attempts=$_CONF_SECRETS_HASHICORP_VAULT_CLIENT_AUTH_ATTEMPTS
	while [ $attempts -gt 0 ]; do
		_vault_do_auth && return
	done
}

_vault_do_auth() {
	_require "$VAULT_ADDR" "VAULT_ADDR"
	vault token lookup >/dev/null 2>&1 || vault login
}

_vault_list() {
	[ -z "$1" ] && return 1

	printf '%s\n' "$1"

	local vault_attribute
	for vault_attribute in $(vault list $1 | sed -e '1,2d'); do
		case $vault_attribute in
		*/)
			vault_attribute=$(printf '%s' "$vault_attribute" | sed -e 's/\/$//')
			_vault_list "$1/$vault_attribute"
			;;
		*)
			printf '%s/%s\n' $1 $vault_attribute
			vault read $1/$vault_attribute | sed -e '1,2d' -e 's/^/  /'
			;;
		esac
	done
}
