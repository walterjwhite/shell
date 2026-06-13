_configuration_user_clear() {
  find ${alt_path}$HOME -type d -maxdepth 1 ! -name '.ssh' ! -name '.data' ! -path "${alt_path}$HOME" -exec rm -rf {} +
  find ${alt_path}$HOME -maxdepth 1 ! -name '.gitconfig' -exec rm -rf {} +
}
