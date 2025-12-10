lib sed.sh

_phone_copy_prepare_target() {
	$_SUDO_CMD mkdir -p "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH"

	_PHONE_COPY_SOURCE_DIRECTORY=$(_readlink "$_PHONE_COPY_SOURCE_DIRECTORY")
	_TARGET_DIRECTORY_NAME=$(basename "$_PHONE_COPY_SOURCE_DIRECTORY")
	if [ -e "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME" ]; then
		_continue_if "Delete existing target?" "Y/n" || _ERROR "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME already exists"

		$_SUDO_CMD rm -rf "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME"
	fi
}

_phone_copy_copy() {
	_INFO "Copying $_PHONE_COPY_SOURCE_DIRECTORY -> $_CONF_PHONE_COPY_TARGET_PATH"

	local source_sed_safe=$(_sed_safe "$_PHONE_COPY_SOURCE_DIRECTORY")
	local file_to_copy
	for file_to_copy in $(find "$_PHONE_COPY_SOURCE_DIRECTORY" -type f ! -name '*.secrets' ! -path '*/.archived/*'); do
		local target=$(printf '%s' "$file_to_copy" | sed -e "s/$source_sed_safe//")
		local target_directory=$(dirname "$target")

		local extension=$(_phone_copy_extension "$file_to_copy")

		$_SUDO_CMD mkdir -p "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME/$target_directory"
		$_SUDO_CMD cp -R "$file_to_copy" "$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME/$target$extension"
	done
}

_phone_copy_extension() {
	if [ $(printf '%s' "$1" | $_CONF_GNU_GREP -Pc '\.[\w]{3,4}$') -gt 0 ]; then
		_DEBUG "file $1, already has an extension"
		return
	fi

	local type=$(file $1 | cut -f2 -d':' | cut -f1 -d',' | sed -e 's/^ //')
	case "$type" in
	"ASCII text" | "UTF-8 text")
		printf '.txt'
		;;
	*)
		_WARN "Unknown type: $type"
		;;
	esac
}
