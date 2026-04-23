_media_encrypt_drive() {
  media_encrypted_device=${media_drive}1

  printf '%s\n' "$media_passphrase" | sudo_run cryptsetup luksFormat --batch-mode -c aes-xts-plain -s 512 --hash sha512 ${media_encrypted_device}
  printf '%s\n' "$media_passphrase" | sudo_run cryptsetup luksOpen ${media_encrypted_device} $media_volume_name

  sudo_run cryptsetup luksHeaderBackup ${media_encrypted_device} --header-backup-file=$media_volume_name/luks
  sudo_run chown $SUDO_USER:$SUDO_USER $media_volume_name/luks

  git add $media_volume_name/luks
}

_media_open_encrypted_drive() {
  sudo_run cryptsetup luksOpen ${media_encrypted_device} $media_volume_name
}

_media_close_encrypted_drive() {
  sudo_run cryptsetup luksClose $media_volume_name
}
