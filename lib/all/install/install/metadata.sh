_metadata_write_app() {
	_sudo rm -f $_TARGET_APPLICATION_METADATA_PATH

	printf '_APPLICATION_NAME="%s"\n' "$_TARGET_APPLICATION_NAME" | _metadata_append
	printf '_APPLICATION_GIT_URL="%s"\n' "$_TARGET_APPLICATION_GIT_URL" | _metadata_append
	printf '_APPLICATION_INSTALL_DATE="%s"\n' "$_TARGET_APPLICATION_INSTALL_DATE" | _metadata_append
	printf '_APPLICATION_BUILD_DATE="%s"\n' "$_TARGET_APPLICATION_BUILD_DATE" | _metadata_append
	printf '_APPLICATION_VERSION="%s"\n' "$_TARGET_APPLICATION_VERSION" | _metadata_append
}

_metadata_append() {
	_append $_TARGET_APPLICATION_METADATA_PATH
}

_metadata_read_value() {
	grep "$1" $_TARGET_APPLICATION_METADATA_PATH 2>/dev/null
}

_install_metadata_is_set() {
	grep -cqm1 "$1" $_APPLICATION_METADATA_PATH 2>/dev/null
}

_install_metadata_append() {
	_append $_APPLICATION_METADATA_PATH
}

