_configuration_user_clear() {
  find ~ -type d -maxdepth 1 ! -name '.ssh' ! -name '.data' ! -path "$HOME" -exec rm -rf {} +
  find ~ -maxdepth 1 ! -name '.gitconfig' -exec rm -rf {} +
}
