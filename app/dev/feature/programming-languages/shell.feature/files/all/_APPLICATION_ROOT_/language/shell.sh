shell_find() {
	[ "$#" -ge 1 ] && shift

	find . -type f -and \( -name "*.sh" -or -path '*/bin/*' -or -name '*Dockerfile*' \) ! -path '*/node_modules/*' \
		! -path '*/target/*' \
		! -path '*/.idea/*' \
		! -path '*/.git/*' "$@"
}
