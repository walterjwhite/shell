_context_id_is_valid() {
	printf '%s' "$1" | $_CONF_GNU_GREP -Pq '^[a-zA-Z0-9_+-]+$' || _ERROR "Context ID *MUST* only contain alphanumeric characters and +-: '^[a-zA-Z0-9_+-]+$' | ($1)"
}

_application_version() {
	grep _APPLICATION_VERSION $_CONF_APPLICATION_LIBRARY_PATH/.metadata 2>/dev/null | cut -f2 -d= | tr -d '"'
}
