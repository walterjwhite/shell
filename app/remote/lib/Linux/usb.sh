#!/bin/sh

_disable_usb() {
	[ -n "$_OPTN_USB_DEVICE_WHITELIST" ] && {
		_WARN "whitelisting: $_OPTN_USB_DEVICE_WHITELIST"
		local usb_device_whitelist_path usb_device_whitelist_find_predicate
		for usb_device_whitelist_path in $(_usb_device_find_by_product "$_OPTN_USB_DEVICE_WHITELIST"); do
			[ -n "$usb_device_whitelist_find_predicate" ] && {
				usb_device_whitelist_find_predicate="$usb_device_whitelist_find_predicate -and "
			}

			usb_device_whitelist_find_predicate="$usb_device_whitelist_find_predicate ! -path $usb_device_whitelist_path/*"
		done

		[ -n "$usb_device_whitelist_find_predicate" ] && {
			usb_device_whitelist_find_predicate="-and ( $usb_device_whitelist_find_predicate ) "
			_DETAIL "using find predicate: $usb_device_whitelist_find_predicate"
		}
	}

	_usb_authorization_do _unauthorize_usb "$usb_device_whitelist_find_predicate"
}

_enable_usb() {
	_usb_authorization_do _authorize_usb
}

_authorize_usb() {
	if [ -e $1 ]; then
		printf '1\n' >$1
	else
		_WARN "$1 does not exist"
	fi
}

_unauthorize_usb() {
	if [ -e $1 ]; then
		printf '0\n' >$1 2>/dev/null
	else
		_WARN "$1 does not exist"
	fi
}

_usb_authorization() {
	_usb_authorization_do cat
}

_usb_authorization_do() {
	local command=$1
	shift

	local usb_hub
	set -f
	for usb_hub in $(find /sys/bus/usb/devices/ -maxdepth 1 -name 'usb*'); do
		$command $usb_hub/authorized_default

		for usb_product in $(find $usb_hub/ -mindepth 2 -name 'product' -type f $@ | sed -e 's/\/product//'); do
			$command $usb_product/authorized
		done
	done

	set +f
}

_usb_device_find_by_product() {
	local usb_hub usb_device whitelist_product
	for whitelist_product in "$@"; do
		for usb_hub in $(find /sys/bus/usb/devices/ -maxdepth 1 -name 'usb*'); do
			for usb_device in $(find $usb_hub/ -name 'product' -type f -exec $_CONF_GNU_GREP -l "^${1}$" {} +); do
				dirname $usb_device
			done
		done
	done
}
