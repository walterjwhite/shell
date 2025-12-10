_phone_copy_install_secrets() {
	if [ ! -e "$_PHONE_COPY_SOURCE_DIRECTORY/.secrets" ]; then
		return 1
	fi

	_INFO "Copying secrets"

	local secret_base_path="$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME"
	local password_store_path="$_CONF_PHONE_COPY_MOUNT_POINT/$_CONF_PHONE_COPY_TARGET_PATH/$_TARGET_DIRECTORY_NAME/.password-store"
	local secret_to_copy
	while read -r secret_to_copy; do
		local secret_directory=$(dirname "$secret_to_copy")

		if [ ! -d "~/.password-store/$secret_to_copy" ]; then
			secret_to_copy="$secret_to_copy.gpg"
		fi

		$_SUDO_CMD mkdir -p "$password_store_path/$secret_directory"
		$_SUDO_CMD cp -R "~/.password-store/$secret_to_copy" "$password_store_path/$secret_to_copy"
	done <"$_PHONE_COPY_SOURCE_DIRECTORY/.secrets"

	_phone_copy_install_password_store "$secret_base_path" "$password_store_path"
}

_phone_copy_install_password_store() {
	$_SUDO_CMD cp ~/.password-store/.gpg-id "$2"
	$_SUDO_CMD cp -R ~/.gnupg "$1"
}
