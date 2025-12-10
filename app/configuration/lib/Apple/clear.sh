_config_user_clear() {

	find ~ -type d -maxdepth 1 \
		! -name '.data' \
		! -name '.ssh' \
		! -path "$HOME" \
		! -name 'Desktop' \
		! -name 'Documents' \
		! -name 'Downloads' \
		! -name 'Library' \
		! -name 'Music' \
		! -name 'Pictures' \
		! -name 'Public' \
		! -name '.Trash' \
		-exec rm -rf {} +

	find ~ -type f -maxdepth 1 ! -name '.gitconfig' -exec rm -f {} +
}
