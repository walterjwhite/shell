_media_encrypt_drive() {
  [ -e "/dev/${media_drive}1.eli" ] && sudo_run geli backup /dev/${media_drive}1 $_GENTOO_DISK_ID/geli

  printf '%s\n' "$media_passphrase" | sudo_run geli init -e aes-xts -l 256 -s 512 -B /dev/${media_drive}1

  printf '%s\n' "$media_passphrase" | sudo_run geli attach /dev/${media_drive}1

  sudo_run geli configure /dev/${media_drive}1.eli
}

_media_open_encrypted_drive() {
  sudo_run geli attach -p -k $conf_media_management_encryption_key_file $conf_media_management_usb_device
}

_media_close_encrypted_drive() {
  sudo_run geli detach $conf_media_management_usb_device
}
