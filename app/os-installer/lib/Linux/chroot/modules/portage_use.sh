_USE_IS_FILE=1
_PATCH_USE() {
	local use=$(printf '%s\n' "$@" | sort -u | tr '\n' ' ')
	printf '# portage use - patches\nUSE="$USE %s"\n' "$use" >>/etc/portage/make.conf
}
