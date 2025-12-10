_online() {
	[ -n "$_SKIP_CONNECTIVITY_CHECK" ] && return

	curl --connect-timeout $_CONF_NETWORK_TEST_TIMEOUT -fs $(_select_random_host) >/dev/null 2>&1 || return 1
}

_select_random_host() {
	local host_count=$(printf '%s\n' $_CONF_NETWORK_TEST_TARGETS | tr ' ' '\n' | wc -l | awk {'print$1'})
	local random_index=$(shuf -i 1-$host_count -n 1)

	printf '%s\n' $_CONF_NETWORK_TEST_TARGETS | tr ' ' '\n' | tail +$random_index | head -1
}
