_run_init_secrets() {
	[ ! -e .application/.secrets ] && return 1

	_INFO "loading secrets -> $_RUN_INSTANCE_DIR"
	secrets unlock 2>/dev/null

	local secret_line secret_key secret_value
	for secret_line in $($_CONF_GNU_GREP -Pv '(^$|^#)' .application/.secrets); do
		secret_env_key="${secret_line%%=*}"
		secret_key="${secret_line#*=}"

		_DEBUG "processing secret: $secret_env_key"
		export $secret_env_key="$(secrets get -out=stdout $secret_key)"
	done
}
