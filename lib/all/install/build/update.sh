_update_remove_commented_code() {
	$_CONF_GNU_SED -i '/^[[:space:]]*#[^!]/d' $1

	$_CONF_GNU_SED -i '/^[[:space:]]*$/d' $1
}

_update_constants() {
	case $1 in
	*/artifacts/install/*)
		_DEBUG "Bypassing update"
		return 1
		;;
	*)
		_DEBUG "Updating constants: $1"
		;;
	esac

	$_CONF_GNU_SED -i "s/__LIBRARY_APPLICATION_PATH__/$_SED_LIBRARY_PATH\/$_TARGET_APPLICATION_NAME/g" $1

	$_CONF_GNU_SED -i "s/__LIBRARY_PATH__/$_SED_LIBRARY_PATH/g" $1
	$_CONF_GNU_SED -i "s/__APPLICATION_NAME__/$_TARGET_APPLICATION_NAME/g" $1
	$_CONF_GNU_SED -i "s/__APPLICATION_VERSION__/$_TARGET_APPLICATION_VERSION/g" $1
	$_CONF_GNU_SED -i "s/__PLATFORM__/$_PLATFORM/g" $1
}

_replace_constants() {
	sed -e "s/__LIBRARY_APPLICATION_PATH__/$_SED_LIBRARY_PATH\/$_TARGET_APPLICATION_NAME/g" \
		-e "s/__LIBRARY_PATH__/$_SED_LIBRARY_PATH/g" \
		-e "s/__APPLICATION_NAME__/$_TARGET_APPLICATION_NAME/g" \
		-e "s/__APPLICATION_VERSION__/$_TARGET_APPLICATION_VERSION/g" \
		-e "s/__PLATFORM__/$_PLATFORM/g"
}
