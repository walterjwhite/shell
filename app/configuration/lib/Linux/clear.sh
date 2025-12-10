_config_user_clear() {
	find ~ -type d -maxdepth 1 ! -name '.ssh' ! -name '.data' ! -path "$HOME" -exec rm -rf {} +
	find ~ -type f -maxdepth 1 ! -name '.gitconfig' -exec rm -f {} +
}
