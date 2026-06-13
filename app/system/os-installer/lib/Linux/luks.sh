lib io/file.sh

_luks_device() {
  luks_device_name_pattern="luks-*"

  [ -n "$1" ] && luks_device_name_pattern=$1

  _luks_device=$(find /dev/mapper -type l -name "$luks_device_name_pattern" | head -1)
  validation_require "$_luks_device" LUKS_DEVICE

  log_warn "using $_luks_device"
}

_luks_encrypted_device() {
  _luks_encrypted_device=$(cryptsetup status $_luks_device | grep device | awk {'print$2'})
  validation_require "$_luks_encrypted_device" LUKS_ENCRYPTED_DEVICE

  log_warn "using $_luks_encrypted_device"
}
