_run_init_env() {
	[ ! -e .application/.env ] && return 1

    _INFO "loading env -> $_RUN_INSTANCE_DIR"

    local env_line
    for env_line in $($_CONF_GNU_GREP -Pv '(^$|^#)' .application/.env); do
        _DEBUG "processing env: $env_line"
        export $env_line
    done
}
