usb_disable() {
  [ -n "$_OPTN_USB_DEVICE_ALLOWLIST" ] && {
    log_warn "allowlisting: $_OPTN_USB_DEVICE_ALLOWLIST"
    local usb_device_allowlist_path usb_device_allowlist_find_predicate
    for usb_device_allowlist_path in $(usb_device_find_by_product "$_OPTN_USB_DEVICE_ALLOWLIST"); do
      [ -n "$usb_device_allowlist_find_predicate" ] && {
        usb_device_allowlist_find_predicate="$usb_device_allowlist_find_predicate -and "
      }

      usb_device_allowlist_find_predicate="$usb_device_allowlist_find_predicate ! -path $usb_device_allowlist_path/*"
    done

    [ -n "$usb_device_allowlist_find_predicate" ] && {
      usb_device_allowlist_find_predicate="-and ( $usb_device_allowlist_find_predicate ) "
      log_detail "using find predicate: $usb_device_allowlist_find_predicate"
    }
  }

  usb_authorization_do unauthorize_usb "$usb_device_allowlist_find_predicate"
}

usb_enable() {
  usb_authorization_do authorize_usb
}

authorize_usb() {
  if [ -e $1 ]; then
    printf '1\n' | sudo_run tee $1 >/dev/null 2>&1
  else
    log_warn "$1 does not exist"
  fi
}

unauthorize_usb() {
  if [ -e $1 ]; then
    printf '0\n' | sudo_run tee $1 >/dev/null 2>&1
  else
    log_warn "$1 does not exist"
  fi
}

usb_authorization() {
  usb_authorization_do cat
}

usb_authorization_do() {
  local _function=$1
  shift

  local usb_hub
  set -f
  for usb_hub in $(find /sys/bus/usb/devices/ -maxdepth 1 -name 'usb*'); do
    $_function $usb_hub/authorized_default

    for usb_product in $(find $usb_hub/ -mindepth 2 -name 'product' -type f $@ | sed -e 's/\/product//'); do
      $_function $usb_product/authorized
    done
  done

  set +f
  unset _function usb_hub usb_product
}

usb_device_find_by_product() {
  local usb_hub usb_device allowlist_product
  for allowlist_product in "$@"; do
    for usb_hub in $(find /sys/bus/usb/devices/ -maxdepth 1 -name 'usb*'); do
      for usb_device in $(find $usb_hub/ -name 'product' -type f -exec $GNU_GREP -l "^${1}$" {} +); do
        dirname $usb_device
      done
    done
  done
}
