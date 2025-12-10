_build_has_invalid_local_var_name() {
	local invalid_local_vars=$(grep -hPo '^[ ]*local [a-zA-Z_0-9]+' $APP_BUILD_OUTPUT_FILE |
		sed -e 's/^.*local //' |
		$_CONF_GNU_GREP -Pv '[a-z_0-9]{3,}' | sort -u)

	local level=_ERROR

	[ -n "$_WARN_ON_ERROR" ] && level=_WARN

	[ -n "$invalid_local_vars" ] && {
		$level "$APP_BUILD_OUTPUT_FILE has invalid local var names: $invalid_local_vars"
	}
}
