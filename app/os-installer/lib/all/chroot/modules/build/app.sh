_APP_IS_FILE=1

_PATCH_APP() {
	local app
	for app in $@; do
		_PRESERVE_LOG=1 _CHILD=1 app-install $app
	done
}
