lib io/file.sh

_mac() {
	_MAC=$(basename $_client_device_file | sed -e "s/\./\:/g")
}

_fqdn() {
	local _device_name=$(basename $(dirname $_client_device_file))

	zone=$(basename $(dirname $(dirname $_client_device_file)))

	_OWNER=$(printf '%s' "$_device_name" | cut -d'.' -f 1 | tr '[:upper:]' '[:lower:]')
	_MANUFACTURER=$(printf '%s' "$_device_name" | cut -d'.' -f 2 | tr '[:upper:]' '[:lower:]')
	_NAME=$(printf '%s' "$_device_name" | cut -d'.' -f 3 | tr '[:upper:]' '[:lower:]')
	_FORM_FACTOR=$(printf '%s' "$_device_name" | cut -d'.' -f 4 | tr '[:upper:]' '[:lower:]')

	_ZONE=$(printf '%s' "$zone" | cut -c 1 | tr '[:upper:]' '[:lower:]')
	_MOBILE_SUFFIX=$(printf '%s' "$zone" | sed -e "s/^.*_mobile/m/")

	if [ "$_MOBILE_SUFFIX" != "$zone" ]; then
		_ZONE=${_ZONE}${_MOBILE_SUFFIX}
	fi

	if [ $(grep -c ^psk= $_client_device_file) -gt 0 ]; then
		_TYPE="w"

		local private_mac=$(grep '^private_mac=.*' $_client_device_file | cut -f2 -d'=')
		[ "$private_mac" ] && _NAME="$_NAME-$private_mac"
	else
		_TYPE="l"
	fi

	_HOST_NAME=${_OWNER}-${_MANUFACTURER}-${_NAME}-${_FORM_FACTOR}
	_FQDN=${_HOST_NAME}.${_ZONE}.${_TYPE}.${_CONF_SYSTEM_CONFIGURATION_DOMAIN_SUFFIX}

	_ZONE_DOMAIN_NAME=${_ZONE}.${_TYPE}.${_CONF_SYSTEM_CONFIGURATION_DOMAIN_SUFFIX}
}

_configure_devices() {
	_require_file "$_CONF_SYSTEM_CONFIGURATION_PATH/configuration"

	. $_CONF_SYSTEM_CONFIGURATION_PATH/configuration
	routers="${IP_PREFIX}.1"
	IP=$STARTING_IP

	for _client_device_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f ! -name '.*'); do
		_fqdn

		if [ $(grep -c '^# STATIC_IP' $_client_device_file) -eq 0 ]; then
			_INFO "Device $(basename $_client_device_file) -> ${IP_PREFIX}.${IP}"

			$_CONF_GNU_SED -i '/IP=/d' $_client_device_file
			printf 'IP=%s.%s\n' "${IP_PREFIX}" "${IP}" >>$_client_device_file

			[ -z "$_CLIENT_IP_START" ] && _CLIENT_IP_START=$IP_PREFIX.$IP

			_CLIENT_IP_END=$IP_PREFIX.$IP

			IP=$((IP + 1))
		else
			_INFO "Device $(basename $_client_device_file) -> $(grep '^IP=.*$' $_client_device_file | cut -f2 -d'=') [fixed]"
		fi

		$_CONF_GNU_SED -i '/FQDN=/d' $_client_device_file
		$_CONF_GNU_SED -i '/HOSTNAME=/d' $_client_device_file
		$_CONF_GNU_SED -i '/DOMAIN=/d' $_client_device_file

		printf 'FQDN=%s\n' "$_FQDN" >>$_client_device_file
		printf 'HOSTNAME=%s\n' "$_HOST_NAME" >>$_client_device_file
		printf 'DOMAIN=%s\n' "$_ZONE_DOMAIN_NAME" >>$_client_device_file
	done
}

_is_restart_services() {
	[ -n "$_SYSTEM_CONFIGURATION_RESTART_SERVICES" ] && return $_SYSTEM_CONFIGURATION_RESTART_SERVICES

	_SYSTEM_CONFIGURATION_RESTART_SERVICES=0
	_WARN 'Restarting services'

	return 0
}
