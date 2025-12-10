_USE_BOOTSTRAP() {
	:
}

_USE_INSTALL() {
	local name_suffix=$(_get_feature_name $1)

	printf '# app.%s%s\n' $_TARGET_APPLICATION_NAME "$name_suffix" | _sudo tee -a /etc/portage/make.conf >/dev/null 2>&1
	printf 'USE="$USE %s"\n' "$(cat $1)" | _sudo tee -a /etc/portage/make.conf >/dev/null 2>&1
}

_USE_UNINSTALL() {
	local name_suffix=$(_get_feature_name $1)

	_sudo $_CONF_GNU_SED -i "s/ app.$_TARGET_APPLICATION_NAME${name_suffix}/ /" /etc/portage/make.conf
}

_USE_IS_INSTALLED() {
	local name_suffix=$(_get_feature_name $1)

	grep -qm1 " # app.$_TARGET_APPLICATION_NAME${name_suffix}" /etc/portage/make.conf
}

_USE_ENABLED() {
	return 0
}

_USE_IS_FILE() {
	return 0
}
