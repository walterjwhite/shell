_configuration_user_clear() {

  find ${alt_path}$HOME -type d -maxdepth 1 \
    ! -name '.data' \
    ! -name '.ssh' \
    ! -path "${alt_path}$HOME" \
    ! -name 'Desktop' \
    ! -name 'Documents' \
    ! -name 'Downloads' \
    ! -name 'Library' \
    ! -name 'Music' \
    ! -name 'Pictures' \
    ! -name 'Public' \
    ! -name '.Trash' \
    -exec rm -rf {} +

  find ${alt_path}$HOME -maxdepth 1 ! -name '.gitconfig' -exec rm -rf {} +
}
